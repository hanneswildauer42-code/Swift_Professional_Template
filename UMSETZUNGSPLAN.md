# UMSETZUNGSPLAN.md

Phasenplan mit atomaren Tasks und Coverage-Gates. Jede Phase ist erst abgeschlossen, wenn:
- Alle Tasks abgehakt sind
- Das Coverage-Gate erfüllt ist
- `just check` ohne Fehler durchläuft
- `docs/PHASE_N_<NAME>.md` als Abschlussbericht existiert

---

## Phase 0 — Scaffolding & Bootstrap

**Ziel:** Projekt baut und testet. Alle Tools laufen.

**Coverage-Gate:** keiner (nur „Smoke grün")

**Tasks:**
- [ ] `./scripts/rename_package.sh <dist> <package>` ausgeführt
- [ ] `./scripts/bootstrap.sh` läuft fehlerfrei durch
- [ ] `swift build` erfolgreich
- [ ] `swift test` erfolgreich (mind. 1 Test)
- [ ] `swiftlint lint` ohne Fehler
- [ ] `xcrun swift-format lint --recursive Sources Tests` ohne Fehler
- [ ] CI-Workflow auf GitHub durchläuft grün (push auf einen Branch + PR)
- [ ] `README.md` mit Kurzbeschreibung gefüllt
- [ ] `docs/PHASE_0_Scaffolding.md` als Abschlussbericht

---

## Phase 1 — Core-Domain-Modelle

**Ziel:** Die zentralen Wert-Typen und Modelle existieren, sind testbar und isoliert.

**Coverage-Gate:** ≥ 50 %

**Tasks:**
- [ ] Domain-Modelle als `struct` mit Codable-Konformität (wenn benötigt)
- [ ] Pure Functions, keine Side Effects in dieser Ebene
- [ ] Mindestens 1 Test pro Modell, der Konstruktion + Equality prüft
- [ ] Edge Cases dokumentiert (leerer String, max-Werte, Sonderzeichen)
- [ ] ADR `0001-domain-modeling.md` mit den Hauptentscheidungen
- [ ] `docs/PHASE_1_Domain.md`

---

## Phase 2 — Services / Use-Cases

**Ziel:** Geschäftslogik, die die Domain-Modelle verwendet, ist implementiert und mit echten Tests abgedeckt.

**Coverage-Gate:** ≥ 70 %

**Tasks:**
- [ ] Services als `protocol` + `final class`/`struct`-Implementierung (Testability)
- [ ] Dependency-Injection statt Singletons
- [ ] Mocks/Stubs für Tests
- [ ] Async-Operationen mit `async/await`, kein DispatchQueue (außer Interop)
- [ ] Error-Handling über typed `enum`-Errors
- [ ] `docs/PHASE_2_Services.md`

---

## Phase 3 — Interface (CLI / UI / HTTP)

**Ziel:** Das Außen-Interface ist implementiert. Bei CLI: ArgumentParser-Setup. Bei UI: SwiftUI/AppKit-Views. Bei Library: das öffentliche API.

**Coverage-Gate:** ≥ 75 %

**Tasks:**
- [ ] Public API in `Sources/<package>/<PublicAPI>.swift` zentral exportiert
- [ ] CLI: Subcommands + Help-Text vollständig
- [ ] UI: ViewModels separat testbar, View-Code ohne Logik
- [ ] Integrations-Tests (mind. ein End-to-End-Pfad)
- [ ] `docs/PHASE_3_Interface.md`

---

## Phase 4 — Integration + Edge Cases

**Ziel:** Alles spielt zusammen. Bekannte Edge Cases sind getestet.

**Coverage-Gate:** ≥ 80 %

**Tasks:**
- [ ] Edge-Case-Liste in `ISSUES.md` durchgearbeitet
- [ ] Negative Tests (Fehlerpfade) explizit abgedeckt
- [ ] Performance-Test (mind. einer für den Hot Path)
- [ ] `docs/PHASE_4_Integration.md`

---

## Phase 5 — Release

**Ziel:** Veröffentlichungs-fähiger Stand.

**Coverage-Gate:** ≥ 80 %

**Tasks:**
- [ ] `CHANGELOG.md` finalisiert (`[Unreleased]` → `[X.Y.Z]`)
- [ ] Version-Bump im Code
- [ ] Tag `vX.Y.Z` setzen
- [ ] GitHub Release mit Binary (oder DMG / Library als Swift Package)
- [ ] `README.md` Installationsanleitung vollständig
- [ ] `SECURITY.md` Kontakt eingetragen
- [ ] LICENSE-Datei gesetzt
- [ ] `docs/PHASE_5_Release.md`

---

## Phasen-Reihenfolge ist verbindlich

Phasen werden **sequentiell** abgearbeitet. Sprünge sind nicht erlaubt — Phase 3 ohne abgeschlossene Phase 2 endet im Chaos. Wenn eine Phase nicht funktioniert, **zurück**, nicht überspringen.

## Coverage-Gates dürfen NICHT gesenkt werden

Wenn das Gate nicht erreicht wird:
1. Tests ergänzen, bis erreicht (`just coverage-check PHASE=N` zeigt den aktuellen Stand)
2. Oder die Phase um „Test-Lücken schließen"-Tasks erweitern
3. **Niemals** Gate-Wert in dieser Datei senken — die Werte sind zusätzlich in `scripts/coverage_check.sh` hartcodiert und werden in CI durchgesetzt. Ein „Gate senken" erfordert also Änderung an beiden Stellen und muss durch Code-Review.

## Verifikation in CI

Die Repo-Variable `COVERAGE_PHASE` (Settings → Variables → Actions) steuert, gegen welche Phase CI prüft. Beim Übergang von Phase N zu N+1 wird die Variable hochgezählt; der erste CI-Lauf der neuen Phase muss das Gate erreichen, sonst rot.
