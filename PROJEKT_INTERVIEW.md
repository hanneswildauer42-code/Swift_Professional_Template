# PROJEKT_INTERVIEW.md

Dieses Interview wird einmalig zu Projekt-Beginn durchgegangen. Claude liest die Antworten und füllt damit `ARCHITEKTUR.md`, `Package.swift`, `CLAUDE.md` und (bei Bedarf) weitere Dateien.

---

## Block 0 — Kritikalität (Pflicht, EINE Frage)

**Q0.** Wie kritisch ist dieses Projekt?
- (a) **Prototyp / Spike** — wegwerfbar, schnelle Iteration, keine Coverage-Gates, keine Security-Pflicht.
- (b) **Internes Tool** — Coverage ≥ 60 %, gitleaks aktiv, ADR ab Phase 2.
- (c) **Produktion / Open Source** — alle Gates aktiv, vollständige Doku, GitHub Releases mit signierten Binaries.

Antwort: …

---

## Block 1 — 5 Pflichtfragen

**Q1. Distribution-Name** (kebab-case, wird zum Binary/Bundle-Identifier):

```
z. B. "my-tool", "file-rename-pro"
```

Antwort: …

**Q2. Package-Name** (PascalCase, der Swift-Namespace):

```
z. B. "MyTool", "FileRenamePro"
```

Antwort: …

**Q3. Kurzbeschreibung** (1–2 Sätze, kommt in `README.md` und ggf. Bundle-Info):

Antwort: …

**Q4. Ziel-Plattform**:
- (a) macOS CLI (Terminal-Tool)
- (b) macOS App (mit UI)
- (c) iOS App
- (d) Cross-platform Library (macOS + iOS + Linux)
- (e) Server-Side-Swift (Linux-Container)

Antwort: …

**Q5. Mindest-OS-Version**:

```
z. B. "macOS 14", "iOS 17", "Linux Ubuntu 22"
```

Antwort: …

---

## Block 2 — Adaptive Folgefragen (je nach Block 1)

### Wenn Q4 = CLI (a):

**Q6.** Soll `swift-argument-parser` als Abhängigkeit ergänzt werden?
- (a) Ja — moderne CLI mit Subcommands, Help-Text
- (b) Nein — eigene Argument-Verarbeitung

### Wenn Q4 = App (b/c):

**Q6.** UI-Framework?
- (a) SwiftUI (modern, deklarativ)
- (b) AppKit / UIKit (klassisch, mehr Kontrolle)
- (c) Hybrid (SwiftUI mit AppKit/UIKit-Interop)

**Q7.** Sind UI-Tests Pflicht?
- (a) Ja — `XCUITest`-Target zusätzlich
- (b) Nein — nur Unit-Tests, UI manuell prüfen

### Wenn Q4 = Library (d):

**Q6.** Soll auch Linux unterstützt werden (Server-Side-Swift)?
- (a) Ja — `swift test` muss auf Linux durchlaufen, CI bekommt zusätzlichen Ubuntu-Job
- (b) Nein — Apple-Plattformen reichen

---

## Block 3 — Optionale Erweiterungen

**Q8.** Persistente Daten? Wenn ja, welcher Mechanismus?
- (a) Keine
- (b) `UserDefaults` / `NSUserDefaults`
- (c) Eigene JSON-Datei in `~/Library/Application Support/<projekt>/`
- (d) SQLite via `SQLite.swift`
- (e) SwiftData / Core Data (nur ab macOS 14+ / iOS 17+)

**Q9.** Netzwerk-Operationen?
- (a) Keine
- (b) `URLSession` direkt
- (c) Eigener Wrapper / dünne Abstraktion
- (d) Externe Library (`AsyncHTTPClient`, `Alamofire`, …)

**Q10.** Konkurrenzmodell?
- (a) Synchron / kein Threading
- (b) Strict-Concurrency aktiviert (Swift 6 default)
- (c) `async/await` mit `actor`s
- (d) `DispatchQueue` (legacy, vermeiden außer für AppKit-Interop)

---

## Block 4 — Distribution & Release

**Q11.** Wie wird das fertige Produkt ausgeliefert?
- (a) Binary auf GitHub Releases (single executable)
- (b) `.dmg` für macOS-Apps
- (c) App Store
- (d) Homebrew-Formula
- (e) Swift Package (als Library für andere Projekte)
- (f) Mehrere — bitte auflisten

**Q12.** Soll der Release-Prozess automatisiert sein?
- (a) Ja — GitHub Actions baut auf Tag-Push automatisch
- (b) Nein — manuell via `just release`

---

## Block 5 — Sicherheit & Compliance (nur bei Q0 = b / c)

**Q13.** Sind Secrets / Credentials Teil der App?
- (a) Nein
- (b) Ja — über Environment-Variablen
- (c) Ja — über macOS-Keychain
- (d) Ja — über eine externe Config-Datei

**Q14.** Open-Source-Lizenz?
- (a) MIT
- (b) Apache-2.0
- (c) BSD-3-Clause
- (d) GPL-3.0
- (e) Proprietär — kein OSS

**Q15.** Code-Signing für Release-Builds?
- (a) Ja — mit Developer-ID, automatisch in CI
- (b) Ja — ad-hoc signiert (`codesign -s -`)
- (c) Nein — unsigniert

---

## Auswertung

Nach den Antworten passt Claude an:
1. **`Package.swift`** — Platzhalter ersetzen, Dependencies ergänzen, Platform setzen
2. **`README.md`** — Kurzbeschreibung einfügen, Build/Test/Install-Sektion
3. **`ARCHITEKTUR.md`** — Komponenten-Diagramm + Daten-Flüsse
4. **`UMSETZUNGSPLAN.md`** — Phasen-Tasks auf das Projekt zuschneiden
5. **`CHANGELOG.md`** — erste Version (`[Unreleased]` → später `[0.1.0]`)
6. **`SECURITY.md`** — Kontakt-E-Mail eintragen (bei OSS)
7. **`LICENSE`** — passende Lizenz wählen
8. Eventuell: `.github/workflows/release.yml` für automatisierte Releases
