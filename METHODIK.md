# METHODIK.md

Die methodischen Leitplanken für die Entwicklung — sprachunabhängig formuliert, mit Swift-spezifischen Konkretisierungen.

## 1. Sequentielle Phasen

Jede Phase aus `UMSETZUNGSPLAN.md` wird **vollständig** abgeschlossen, bevor die nächste beginnt. Ein Phasen-Abschluss erfordert:

1. Alle Tasks abgehakt
2. Coverage-Gate erfüllt
3. `just check` grün
4. `docs/PHASE_N_<NAME>.md` als Abschlussbericht
5. Commit mit Tag `phase-N-complete` (optional)

## 2. Testen ist Pflicht, nicht Option

- **Jede Funktion** mit Side Effects oder nicht-trivialer Logik bekommt mindestens einen Test.
- **Behavioral Tests** (`Given/When/Then`) bevorzugen Implementierungs-Details-Tests.
- **Edge Cases** werden in `ISSUES.md` notiert und nach Bearbeitung als Test materialisiert.
- **UI** bekommt mindestens Snapshot-Tests oder XCUITest-Smoke (nach Interview-Entscheidung).

### Swift-spezifisch

```swift
// XCTest-Struktur
final class MyServiceTests: XCTestCase {
    func test_myFunction_whenInputIsValid_returnsExpectedResult() {
        // Given
        let sut = MyService(dependency: MockDep())
        // When
        let result = sut.myFunction(input: "valid")
        // Then
        XCTAssertEqual(result, .expected)
    }
}
```

Test-Naming: `test_<unit>_<condition>_<expectation>()`.

## 3. Coverage-Messung

```bash
swift test --enable-code-coverage
just coverage-report
```

Coverage wird **pro Phase** geprüft. Reine "Anzahl Test-Funktionen" ist KEIN Maß für Qualität, aber unter dem Gate-Wert ist das Projekt **per Definition unvollständig**.

## 4. Secrets-Policy

**Niemals** Tokens, Passwörter, API-Keys im Code:

```swift
// VERBOTEN
let apiKey = "sk-abc123…"

// ERLAUBT
guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
    throw ConfigError.missingAPIKey
}
```

Quellen für Secrets:
1. Environment-Variablen (für CLI)
2. macOS Keychain (für Apps)
3. `~/.config/<projekt>/secrets.json` (mode 0600, in `.gitignore`)

`gitleaks` läuft als pre-commit-Hook und in CI — verhindert versehentliche Commits.

## 5. Logging

Verwendung: `os.Logger` (macOS 11+ / iOS 14+):

```swift
import os
private let log = Logger(subsystem: "de.example.MyApp", category: "MyService")

log.info("Started request to \(url)")
log.error("Failed: \(error)")
```

**Keine `print()` im Produktcode.** `print()` darf in Tests bleiben und in Debug-Hilfsfunktionen, die niemals released werden.

## 6. Fehlerbehandlung

- Errors typed über `enum`, niemals als opaker `Error`-Typ in Public APIs:

```swift
enum DownloadError: Error {
    case timeout
    case invalidResponse(statusCode: Int)
    case decoding(underlying: Error)
}
```

- `throws` an der Service-Grenze, **nicht** überall durchschleifen.
- An der UI-/CLI-Grenze: Errors fangen, in lesbare Meldung umwandeln.

## 7. Concurrency

- **Default:** `async/await` + `actor`s.
- **Niemals** `DispatchQueue.main.sync` auf der Main-Queue (Deadlock-Risiko).
- **AppKit/UIKit-Interop**: `@MainActor` markieren, nicht `DispatchQueue.main.async` schachteln.
- **Strict Concurrency** ist in `Package.swift` aktiviert — Warnings ernst nehmen.

## 8. Versionierung (SemVer)

```
MAJOR.MINOR.PATCH
  │     │     └── Bug Fixes, keine API-Änderungen
  │     └──────── Neue Features, abwärtskompatibel
  └────────────── Breaking Changes
```

Version steht an **einer** Stelle (i. d. R. `Sources/<Package>/<Package>.swift` oder eigene `Version.swift`).

Releases:
1. `CHANGELOG.md` aktualisieren (`[Unreleased]` → `[X.Y.Z]`)
2. Version-Bump
3. Commit `Release vX.Y.Z`
4. Tag `git tag vX.Y.Z`
5. Push: `git push origin main --tags`
6. GitHub Release erstellen (manuell oder via Workflow)

## 9. Git-Commits

- **Sprache:** Deutsch (Anpassen wenn Team Englisch bevorzugt)
- **Format:** Imperativ, erste Zeile ≤ 72 Zeichen
- **Body:** Erklärt das **warum**, nicht das **was** (das steht im Diff)
- **Trailer:** Co-Authored-By bei KI-Beiträgen

```
Add file-type column to commander table

Total-Commander-Nutzer erwarten eine "Typ"-Spalte. Implementiert mit
NSWorkspace.shared.localizedDescription(forType:) — liefert dieselben
Strings wie der Finder.

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Niemals** `git config user.name/email` global setzen — wenn nötig, inline:

```bash
git -c user.name="Max Mustermann" -c user.email="max@example.de" commit -m "…"
```

## 10. ADRs (Architecture Decision Records)

Größere Entscheidungen festhalten in `docs/adr/NNNN-titel.md`:
- Welche Library?
- Welches Storage-Format?
- Welche Plattform-Mindestversion?
- Warum diese Concurrency-Strategie?

Template: `docs/adr/0000-template.md`. Nummern fortlaufend, alte ADRs nicht löschen — bei Änderung neue ADR mit Verweis erstellen ("Supersedes 0003").

## 11. Pre-Commit-Hooks

```bash
pre-commit install   # einmalig
```

Läuft vor jedem `git commit`:
- `swiftlint lint`
- `swift-format lint`
- `gitleaks detect`
- Whitespace / Large-Files / Private-Keys

Hooks **niemals** mit `--no-verify` umgehen, außer in absoluten Notfällen (und dann erklären, was schiefging).

## 12. CI

GitHub Actions auf `macos-14`. Job-Matrix:
- Lint
- Build (Debug)
- Test + Coverage
- Security (gitleaks)

Bei Fehlschlag: **kein Merge**. Branch-Protection-Rules auf `main` setzen (im GitHub-Settings).
