# LEARNINGS.md

Erkenntnisse, die während der Entwicklung auftauchen und für spätere Sessions relevant sind. Pro Session ein Block, neueste oben.

> **Format:** `## YYYY-MM-DD — Kurztitel` → 2–6 Bullets → fertig.
> Keine Romane, keine Implementierungs-Details (dafür gibt es Code-Kommentare).
> Was hier rein gehört: überraschende Tool-Verhaltensweisen, falsche Annahmen, Lessons-Learned.

---

## YYYY-MM-DD — Beispiel-Eintrag

- swift-format aus der Xcode-Toolchain (`xcrun swift-format`) hat strenge Indent-Regeln, die mit dem Default-4-Space-Code des Templates kollidieren — `.swift-format` setzt `indentation.spaces = 4` explizit.
- `swift test --enable-code-coverage` erzeugt `.profdata` unter `.build/`. Pfad ist nicht offiziell stabil — `find` verwenden statt hardcoded.
- `gitleaks` läuft als pre-commit-Hook UND in CI — doppelt hält besser, weil pre-commit-Hooks lokal mit `--no-verify` umgangen werden können.
