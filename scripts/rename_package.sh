#!/usr/bin/env bash
# Ersetzt PROJEKT_NAME / PROJEKT_PACKAGE durch die echten Namen.
# Verwendung:
#   ./scripts/rename_package.sh <dist-name> <package-name>
#   z. B.: ./scripts/rename_package.sh my-tool MyTool
set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <dist-name> <package-name>"
    echo "  dist-name      = z. B. 'my-tool' (kebab-case)"
    echo "  package-name   = z. B. 'MyTool' (PascalCase)"
    exit 1
fi

DIST_NAME="$1"
PKG_NAME="$2"

# --- Input-Validierung -----------------------------------------------------
#
# Wir lassen NUR ASCII-Zeichen zu, die in Swift-Identifiern und kebab-case-
# Dateinamen sinnvoll sind. Sonderzeichen (/, &, ., Backslash, Whitespace)
# würden sed-Substitutionen zerlegen und Quellen korrumpieren.

if ! [[ "$DIST_NAME" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
    echo "✗ DIST_NAME muss kebab-case sein: [a-z0-9][a-z0-9_-]*"
    echo "  Erhalten: '$DIST_NAME'"
    exit 2
fi

if ! [[ "$PKG_NAME" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
    echo "✗ PKG_NAME muss PascalCase sein: [A-Z][A-Za-z0-9]*"
    echo "  Erhalten: '$PKG_NAME'"
    exit 2
fi

# --- Ersetzungen -----------------------------------------------------------
#
# Reihenfolge: zuerst PROJEKT_PACKAGE, dann PROJEKT_NAME — weil
# PROJEKT_NAME als Substring in PROJEKT_PACKAGE vorkommt. Würden wir
# PROJEKT_NAME zuerst durch z. B. "my-tool" ersetzen, blieb von
# PROJEKT_PACKAGE der Müll "my-tool_PACKAGE" übrig.
#
# Wir nutzen '|' als sed-Trenner (nicht '/'), damit Pfade als Eingaben
# kein Problem wären. (Die Validierung oben verbietet '/' ohnehin — der
# Trenner-Wechsel ist Defense in Depth.)
#
# `sed -i` ist plattformabhängig: GNU akzeptiert `-i` direkt, BSD/macOS
# verlangt ein Backup-Suffix-Argument (`-i ''` für kein Backup). Wir
# detektieren das anhand des sed-Versions-Strings.

if sed --version 2>/dev/null | grep -q GNU; then
    SED_INPLACE=(-i)
else
    SED_INPLACE=(-i '')
fi

echo "→ Ersetze in Quelldateien …"
find . \
    -path './.git' -prune -o \
    -path './.build' -prune -o \
    -path './.swiftpm' -prune -o \
    -path './scripts/rename_package.sh' -prune -o \
    -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.yaml' -o -name '*.md' -o -name 'Justfile' -o -name '.swiftlint.yml' -o -name 'Package.swift' \) \
    -exec sed "${SED_INPLACE[@]}" "s|PROJEKT_PACKAGE|$PKG_NAME|g; s|PROJEKT_NAME|$DIST_NAME|g" {} +

echo "→ Verzeichnisse umbenennen …"
if [ -d "Sources/PROJEKT_PACKAGE" ]; then
    mv "Sources/PROJEKT_PACKAGE" "Sources/$PKG_NAME"
fi
if [ -d "Tests/PROJEKT_PACKAGETests" ]; then
    mv "Tests/PROJEKT_PACKAGETests" "Tests/${PKG_NAME}Tests"
fi
if [ -f "Sources/$PKG_NAME/PROJEKT_PACKAGE.swift" ]; then
    mv "Sources/$PKG_NAME/PROJEKT_PACKAGE.swift" "Sources/$PKG_NAME/$PKG_NAME.swift"
fi
if [ -f "Tests/${PKG_NAME}Tests/PROJEKT_PACKAGETests.swift" ]; then
    mv "Tests/${PKG_NAME}Tests/PROJEKT_PACKAGETests.swift" "Tests/${PKG_NAME}Tests/${PKG_NAME}Tests.swift"
fi

echo "→ swift build zur Verifikation …"
if ! swift build; then
    echo
    echo "✗ swift build hat fehlgeschlagen. Bitte die Fehler oben prüfen."
    exit 3
fi

echo
echo "✓ Umbenennung abgeschlossen:"
echo "  Distribution-Name:  $DIST_NAME"
echo "  Package-Name:       $PKG_NAME"
echo
echo "Nächste Schritte: PROJEKT_INTERVIEW.md beantworten, dann mit Phase 0 beginnen."
