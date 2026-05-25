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

echo "→ Ersetze in Quelldateien …"
# Reihenfolge wichtig: zuerst Package-Name (länger), dann Dist-Name
find . \
    -path './.git' -prune -o \
    -path './.build' -prune -o \
    -path './.swiftpm' -prune -o \
    -path './scripts/rename_package.sh' -prune -o \
    -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.yaml' -o -name '*.md' -o -name 'Justfile' -o -name '.swiftlint.yml' -o -name 'Package.swift' \) \
    -exec sed -i '' "s/PROJEKT_PACKAGE/$PKG_NAME/g; s/PROJEKT_NAME/$DIST_NAME/g" {} +

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
swift build

echo
echo "✓ Umbenennung abgeschlossen:"
echo "  Distribution-Name:  $DIST_NAME"
echo "  Package-Name:       $PKG_NAME"
echo
echo "Nächste Schritte: PROJEKT_INTERVIEW.md beantworten, dann mit Phase 0 beginnen."
