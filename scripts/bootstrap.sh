#!/usr/bin/env bash
# Bootstrap-Script: installiert alle Tools, die das Template erwartet.
# Verwendung: ./scripts/bootstrap.sh
set -euo pipefail

echo "→ Swift_Professional_Template Bootstrap"
echo

# 1. Homebrew vorhanden?
if ! command -v brew >/dev/null 2>&1; then
    echo "✗ Homebrew nicht gefunden."
    echo "  Installation: https://brew.sh"
    exit 1
fi

# 2. Erforderliche Tools
REQUIRED_TOOLS=(
    swiftlint       # Linting
    just            # Task-Runner
    pre-commit      # Git-Hooks
    gitleaks        # Secret-Scan
)

OPTIONAL_TOOLS=(
    xcbeautify      # Schönere xcodebuild-Ausgabe
    xcresultparser  # JUnit/Cobertura-Export
)

echo "→ Pflicht-Tools per Homebrew installieren …"
for tool in "${REQUIRED_TOOLS[@]}"; do
    if brew list "$tool" >/dev/null 2>&1; then
        echo "  ✓ $tool bereits vorhanden"
    else
        echo "  • $tool installieren …"
        brew install "$tool"
    fi
done

echo
echo "→ Optionale Tools (für CI-Reports / schönere Ausgabe):"
for tool in "${OPTIONAL_TOOLS[@]}"; do
    if brew list "$tool" >/dev/null 2>&1; then
        echo "  ✓ $tool bereits vorhanden"
    else
        echo "  • $tool installieren … (optional, Abbruch mit Ctrl-C)"
        brew install "$tool" || echo "    (übersprungen)"
    fi
done

# 3. swift-format kommt aus der Xcode-Toolchain
echo
if xcrun --find swift-format >/dev/null 2>&1; then
    echo "✓ swift-format aus Xcode-Toolchain: $(xcrun --find swift-format)"
else
    echo "⚠ swift-format nicht gefunden — Xcode-CLI-Tools installieren:"
    echo "    xcode-select --install"
fi

# 4. Pre-commit-Hooks aktivieren
echo
if [ -f .pre-commit-config.yaml ]; then
    echo "→ Pre-commit-Hooks installieren …"
    pre-commit install
    echo "  ✓ Hooks aktiv (laufen vor jedem Commit)"
fi

# 5. Initiales Build + Test
#
# Wichtig: `swift build | tail -3` würde wegen `tail` immer Exit 0 liefern,
# und `if pipeline; then` deaktiviert zusätzlich `set -e`. Wir prüfen
# darum den Exit-Status explizit und loggen bei Fehler die letzten 20
# Zeilen, damit der Nutzer sieht, was schiefging.

BOOTSTRAP_LOG=$(mktemp -t swift-bootstrap.XXXXXX)
trap 'rm -f "$BOOTSTRAP_LOG"' EXIT

echo
echo "→ Smoke-Build …"
if swift build > "$BOOTSTRAP_LOG" 2>&1; then
    echo "  ✓ swift build OK"
else
    echo "  ✗ swift build fehlgeschlagen — letzte Zeilen:"
    tail -20 "$BOOTSTRAP_LOG" | sed 's/^/    /'
    exit 1
fi

echo
echo "→ Smoke-Test …"
if swift test > "$BOOTSTRAP_LOG" 2>&1; then
    echo "  ✓ swift test OK"
else
    echo "  ✗ swift test fehlgeschlagen — letzte Zeilen:"
    tail -20 "$BOOTSTRAP_LOG" | sed 's/^/    /'
    exit 1
fi

echo
echo "✓ Bootstrap fertig. Nächste Schritte:"
echo "  • just         → verfügbare Recipes anzeigen"
echo "  • just check   → komplette Prüfkette laufen lassen"
echo "  • PROJEKT_INTERVIEW.md beantworten und Platzhalter ersetzen"
