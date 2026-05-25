# Swift Professional Template

Vorlage für professionelle Swift-Projekte mit Claude Code. Spiegel des Python-Templates (`Professional_Template`), mit Swift-spezifischer Toolchain.

> **Hinweis:** Dieses Repository ist eine **Vorlage**, kein lauffähiges Projekt. Erst nach dem Initialisierungs-Interview und der Umbenennung (`scripts/rename_package.sh`) sind alle Platzhalter ersetzt.

## Verwendung

1. Kopiere diesen Ordner in dein neues Projektverzeichnis
2. Öffne Claude Code in diesem Verzeichnis
3. Claude liest `CLAUDE.md` und erkennt den Initialisierungsmodus
4. Das Projekt-Interview (`PROJEKT_INTERVIEW.md`) startet automatisch
5. Nach deinen Antworten ersetzt Claude die Platzhalter (oder du rufst `./scripts/rename_package.sh <dist-name> <package-name>` direkt auf)
6. Bootstrap: `./scripts/bootstrap.sh` (installiert swiftlint, just, pre-commit, gitleaks und führt initialen Build/Test aus)
7. Phase 0 (Scaffolding) beginnt

## Schnellstart ohne Interview

```bash
git clone <template-repo> mein-projekt
cd mein-projekt
rm -rf .git && git init
./scripts/rename_package.sh my-tool MyTool
./scripts/bootstrap.sh
just check
```

## Enthaltene Dateien

### Dokumentation

| Datei | Zweck |
|-------|-------|
| `README.md` | Diese Datei — Anleitung zur Template-Verwendung |
| `CLAUDE.md` | Operative Steuerung — wird von Claude Code bei jedem Befehl gelesen |
| `PROJEKT_INTERVIEW.md` | Block 0 (Kritikalität) + 5 Pflichtfragen + adaptive Folgeblöcke |
| `UMSETZUNGSPLAN.md` | Phasenplan mit atomaren Tasks + Coverage-Gates pro Phase |
| `ARCHITEKTUR.md` | Technische Architektur (wird nach Interview gefüllt) |
| `METHODIK.md` | Vorgehensweise, Secrets-Policy, Logging, Versionierung |
| `LEARNINGS.md` | Erkenntnisse pro Session |
| `ISSUES.md` | Lightweight Issue-Tracker |
| `CHANGELOG.md` | Keep-a-Changelog-Format, SemVer |
| `SECURITY.md` | Vulnerability-Disclosure-Policy |
| `LICENSE` | MIT-Platzhalter |
| `docs/PHASE_TEMPLATE.md` | Vorlage für Phasen-Abschlussberichte |
| `docs/adr/0000-template.md` | ADR-Vorlage |

### Konfiguration

| Datei | Zweck |
|-------|-------|
| `Package.swift` | SPM-Manifest mit Platform `.macOS(.v14)` und StrictConcurrency-Feature |
| `Justfile` | Kanonische Befehle: `bootstrap`, `lint`, `format`, `test`, `coverage`, `check`, `prepush` |
| `.swiftlint.yml` | SwiftLint-Regeln mit projekt-angepassten Schwellen |
| `.swift-format` | swift-format-Konfiguration (4-Space-Indent, lineLength 140) |
| `.pre-commit-config.yaml` | Hooks: swiftlint, swift-format, gitleaks, whitespace, secrets |
| `.gitignore` | `.build`, `.swiftpm`, `DerivedData`, Logs, IDE-Files |
| `.github/workflows/ci.yml` | CI: build + test + coverage + Lint + Security (gitleaks) |
| `.github/dependabot.yml` | Wöchentliche Updates für GitHub Actions + Swift-Packages |
| `scripts/bootstrap.sh` | Tool-Installation (Homebrew) + Smoke-Build/Test |
| `scripts/rename_package.sh` | Platzhalter durch echte Namen ersetzen |

### Source-Struktur (SPM-Standard)

```
Sources/PROJEKT_PACKAGE/
    PROJEKT_PACKAGE.swift      ← Library-Einstieg
Tests/PROJEKT_PACKAGETests/
    PROJEKT_PACKAGETests.swift ← Smoke-Tests
```

## Toolchain-Anforderungen

| Tool | Mindest-Version | Quelle |
|------|-----------------|--------|
| Xcode / Swift | 5.9+ | Mac App Store |
| Homebrew | aktuell | brew.sh |
| SwiftLint | 0.55+ | `brew install swiftlint` |
| just | 1.20+ | `brew install just` |
| pre-commit | 3.0+ | `brew install pre-commit` |
| gitleaks | 8.20+ | `brew install gitleaks` |
| swift-format | aus Xcode-Toolchain | bereits enthalten |

Optional:
- `xcbeautify` für schönere CI-Ausgabe
- `xcresultparser` für JUnit-XML-Export

## Unterschied zum Python-Template

| Bereich | Python-Template | Swift-Template |
|---------|-----------------|----------------|
| Dependency-Management | `uv` + `pyproject.toml` | `swift package` + `Package.swift` |
| Lint | `ruff check` | `swiftlint lint` |
| Format | `ruff format` | `swift-format` |
| Type-Check | `mypy --strict` | entfällt (Swift statisch getypt) |
| Test | `pytest` | `swift test` (XCTest) |
| Coverage | `pytest-cov` | `swift test --enable-code-coverage` + `llvm-cov` |
| Audit | `pip-audit` | `swift package audit-dependencies` (ab Swift 5.10+) |
| Secrets | `gitleaks` | `gitleaks` (identisch) |
| CI-Runner | Ubuntu | macOS-14 (ARM) |

Die **methodischen Dokumente** (`CLAUDE.md`, `PROJEKT_INTERVIEW.md`, `UMSETZUNGSPLAN.md`, `METHODIK.md`, `ARCHITEKTUR.md`, `LEARNINGS.md`, `ISSUES.md`) sind **sprachunabhängig** und 1:1 vom Python-Template übernommen — nur die Phasen-Tasks und die Tool-Referenzen sind auf Swift gedreht.

## Phasen-Konzept (Kurzfassung)

| Phase | Inhalt | Coverage-Gate |
|-------|--------|---------------|
| 0 | Scaffolding: `swift build` läuft, `swift test` läuft, Lint sauber | — |
| 1 | Core-Domain-Modelle + Smoke-Tests | ≥ 50 % |
| 2 | Services / Use-Cases | ≥ 70 % |
| 3 | Interface (CLI/UI/HTTP) | ≥ 75 % |
| 4 | Integration + Edge Cases | ≥ 80 % |
| 5 | Release: Binary-Distribution, Doku, Tag | ≥ 80 % |

Detailliert in `UMSETZUNGSPLAN.md` und `METHODIK.md`.
