# CLAUDE.md — Operative Steuerung für Claude Code

Diese Datei wird von Claude Code bei **jeder** Interaktion in diesem Projekt gelesen. Sie regelt den Initialisierungsmodus und die laufende Entwicklung.

---

## Initialisierungsmodus

**Auslöser:** Wenn diese Datei beim Sessionstart die Platzhalter `PROJEKT_NAME` / `PROJEKT_PACKAGE` enthält UND keine `Package.resolved` existiert, befindet sich das Projekt im **Init-Mode**.

**Schritte:**
1. Begrüße den Nutzer kurz und erkläre, dass jetzt das Projekt-Interview startet.
2. Öffne `PROJEKT_INTERVIEW.md`. Stelle **Block 0 (Kritikalität)** sowie die **5 Pflichtfragen** in dieser Reihenfolge:
   - Distribution-Name (kebab-case)
   - Package-Name (PascalCase)
   - Kurzbeschreibung (1–2 Sätze)
   - Ziel-Plattform (macOS-CLI / macOS-App / iOS-App / cross-platform Library)
   - Mindest-OS-Version
3. Adaptive Folge-Blöcke je nach Antworten (CLI → ArgumentParser? App → Test-Strategy ohne UI-Tests?).
4. Ersetze nach den Antworten alle Platzhalter durch `./scripts/rename_package.sh <dist> <package>`.
5. Befülle `ARCHITEKTUR.md` mit dem geklärten Setup.
6. Führe `./scripts/bootstrap.sh` aus — installiert Tools, baut Smoke, lässt Tests laufen.
7. Erkläre kurz, wie Phase 0 abläuft, dann übergib zurück an den Nutzer.

---

## Laufende Entwicklung

### Pflicht-Befehl vor jedem Commit

```bash
just check     # lint + format-check + test (lokal)
just prepush   # zusätzlich security-scan (vor Push)
```

### Coverage-Gates

| Phase | Mindest-Coverage |
|-------|-------------------|
| 0 | nicht erforderlich, aber `swift build` + Smoke-Test grün |
| 1 | ≥ 50 % |
| 2 | ≥ 70 % |
| 3 | ≥ 75 % |
| 4 | ≥ 80 % |
| 5 | ≥ 80 % |

Ein Phasen-Abschluss ohne erfülltes Gate ist **nicht erlaubt**. Wenn das Gate nicht erreicht wird, entweder mehr Tests schreiben oder die Phase erweitern — nicht das Gate senken.

### Tests sind Pflicht

**Jede neue Funktion** bekommt mindestens einen XCTest. Falls Behaviour-Test schwierig ist (z. B. UI), zumindest ein Smoke-Test, der den Code-Pfad durchläuft.

### Logging und Fehlerbehandlung

- Logging über `os.Logger` (macOS 11+) oder ein eigener Wrapper.
- Keine `print()` im produktiven Code (Debug-`print` darf in Tests bleiben).
- Errors typed (`enum`), nicht `Error` als opaker Typ.

### Secrets

- **Keine** Tokens, API-Keys, Passwörter in den Quellcode. Punkt.
- Konfiguration über Environment-Variablen oder `~/.config/<projekt>/config.json`.
- `gitleaks` läuft sowohl als pre-commit-Hook als auch in CI.

### Versionierung

- **SemVer**: `MAJOR.MINOR.PATCH`
- Version steht an EINER Stelle (i. d. R. in der Library-Datei selbst oder in einer separaten `Version.swift`).
- Bei Releases: Tag setzen, `CHANGELOG.md` aktualisieren, GitHub Release erstellen.

### Architektur-Entscheidungen

- Größere Entscheidungen als ADR (`docs/adr/NNNN-titel.md`) festhalten.
- Template in `docs/adr/0000-template.md`.

---

## Build-Befehle (Cheatsheet)

```bash
swift build                          # Debug-Build
swift build -c release               # Release-Build
swift test                           # Tests
swift test --enable-code-coverage    # Tests + Coverage
swift test --filter MyTestSuite      # Einzelne Test-Suite
swiftlint lint                       # Lint
xcrun swift-format format -i -r Sources Tests   # Format
just check                           # Komplette Prüfkette
just prepush                         # Vor Push
```

---

## Was Claude NICHT tun soll

- **Niemals** Tests deaktivieren, um eine Phase abzuschließen.
- **Niemals** das Coverage-Gate senken.
- **Niemals** Secrets in den Code schreiben — auch nicht "nur zum Testen".
- **Niemals** `swift build -c release` als Smoke-Test verwenden (zu langsam).
- **Niemals** Force-Push auf `main`.
- **Niemals** `git config user.name/user.email` global ändern — wenn nötig, inline mit `git -c user.name=… commit`.

---

## Was Claude IMMER tun soll

- **Vor jeder Code-Änderung**: Tests aktualisieren oder neue schreiben.
- **Nach jeder Funktion**: `just check` lokal laufen lassen.
- **Bei jedem Commit**: Aussagekräftige Message (deutsch, mit Kontext), Co-Authored-By bei KI-Beiträgen.
- **Bei jedem Release**: CHANGELOG.md + Tag + GitHub Release.
- **Bei jeder Architektur-Entscheidung**: ADR erstellen.

---

**Status:** Init-Mode aktiv, solange `PROJEKT_NAME` / `PROJEKT_PACKAGE` in `Package.swift` stehen.
