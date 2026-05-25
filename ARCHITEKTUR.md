# ARCHITEKTUR.md

> **Status: leer.** Diese Datei wird nach Abschluss des `PROJEKT_INTERVIEW.md` von Claude befüllt.

## 1. Überblick

_Wird im Interview gesetzt: Was tut das Projekt? Welche Zielgruppe?_

## 2. Komponenten

_Wird im Interview gesetzt: Module / Verzeichnisse / Verantwortlichkeiten._

```
Sources/<Package>/
├── …
└── …
```

## 3. Daten-Modelle

_Phase 1 — wird mit konkreten `struct`/`enum`-Definitionen befüllt._

## 4. Service-Schicht

_Phase 2 — Protokolle, Implementierungen, Dependency-Graph._

## 5. Interface-Schicht

_Phase 3 — CLI-Subcommands ODER UI-Views ODER Public API._

## 6. Threading / Concurrency

_Welches Modell? Actor-Hierarchie? Hot Paths?_

## 7. Persistenz

_Wenn vorhanden: wo werden Daten gespeichert, wann, wie versioniert?_

## 8. Externe Abhängigkeiten

| Package | Version | Zweck |
|---------|---------|-------|
| _z. B. swift-argument-parser_ | _1.3.0_ | _CLI-Argumente_ |

## 9. Build & Distribution

_Phase 5 — Release-Mechanismus, Code-Signing, Update-Strategie._

## 10. Entscheidungs-Historie (ADRs)

_Verweise auf `docs/adr/NNNN-titel.md`._
