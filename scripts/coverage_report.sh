#!/usr/bin/env bash
# Druckt einen Coverage-Text-Report aus den letzten `swift test --enable-code-coverage`-
# Daten. Sucht die xctest-Binary zuverlässig im SPM-Build-Output.
#
# Verwendung: ./scripts/coverage_report.sh
set -euo pipefail

PROF=$(find .build -name 'default.profdata' 2>/dev/null | head -1)
if [ -z "$PROF" ]; then
    echo "✗ Keine Coverage-Daten gefunden."
    echo "  Erst 'swift test --enable-code-coverage' (oder 'just test-coverage') laufen lassen."
    exit 1
fi

# SPM legt das xctest-Bundle ab unter:
#   .build/<arch>/debug/<Package>PackageTests.xctest
# Auf macOS ist die Binary innerhalb des Bundles:
#   <bundle>/Contents/MacOS/<Package>PackageTests
# Auf Linux gibt es kein Bundle — die Binary liegt direkt im debug-Verzeichnis.

BUNDLE=$(find .build -name '*PackageTests.xctest' -type d 2>/dev/null | head -1)
if [ -n "$BUNDLE" ]; then
    BASE=$(basename "$BUNDLE" .xctest)
    BIN="$BUNDLE/Contents/MacOS/$BASE"
else
    BIN=$(find .build -type f -name '*PackageTests' -not -name '*.o' 2>/dev/null | head -1)
fi

if [ -z "$BIN" ] || [ ! -f "$BIN" ]; then
    echo "✗ xctest-Binary nicht gefunden unter .build/."
    echo "  Suche: PackageTests-Bundle (macOS) oder Test-Binary (Linux)."
    exit 1
fi

xcrun llvm-cov report "$BIN" \
    -instr-profile="$PROF" \
    -ignore-filename-regex='.build|Tests|\.swiftpm'
