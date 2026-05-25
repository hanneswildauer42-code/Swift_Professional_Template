# Security Policy

## Reporting a Vulnerability

Wenn Sie eine Sicherheitslücke in diesem Projekt finden, melden Sie sie bitte **nicht** über einen öffentlichen GitHub Issue.

Stattdessen senden Sie eine E-Mail an: `security@<DOMAIN>` _(nach Interview eintragen)_

Bitte fügen Sie folgende Informationen bei:
- Beschreibung der Lücke
- Schritte zur Reproduktion
- Mögliche Auswirkungen
- Falls vorhanden: Vorschlag zur Behebung

Wir antworten innerhalb von 72 Stunden. Nach Bestätigung der Lücke arbeiten wir an einem Fix und koordinieren mit Ihnen den Veröffentlichungszeitpunkt (üblicherweise 30 Tage nach Fix).

## Unterstützte Versionen

Sicherheits-Fixes erhalten nur die aktuelle Major-Release-Linie:

| Version | Supported |
|---------|-----------|
| 0.x | ✅ |

## Bekannte Sicherheits-Maßnahmen

- **Secret-Scanning** via gitleaks (pre-commit + CI)
- **Dependency-Updates** via Dependabot (wöchentlich)
- **Code-Signing** für Release-Binaries (sofern in Interview vereinbart)
- **Keine** Telemetrie, keine externen Netzwerk-Calls ohne Nutzer-Konsens
