#!/usr/bin/env bash
# Vergleicht die Total-Line-Coverage gegen das Phasen-Gate aus UMSETZUNGSPLAN.md
# und bricht mit Exit ≠ 0 ab, wenn die Schwelle nicht erreicht ist.
#
# Verwendung:
#   ./scripts/coverage_check.sh <phase>
#   z. B.: ./scripts/coverage_check.sh 2     # ≥ 70 % erforderlich
set -euo pipefail

PHASE="${1:-0}"

# Phasen-Gates aus UMSETZUNGSPLAN.md / CLAUDE.md.
# WICHTIG: diese Werte werden auch von CI durchgesetzt. Senken ist verboten.
case "$PHASE" in
    0) GATE=0  ;;
    1) GATE=50 ;;
    2) GATE=70 ;;
    3) GATE=75 ;;
    4) GATE=80 ;;
    5) GATE=80 ;;
    *)
        echo "✗ Ungültige Phase: '$PHASE' (erlaubt: 0–5)"
        exit 2
        ;;
esac

if [ "$GATE" -eq 0 ]; then
    echo "Phase 0: kein Coverage-Gate (nur Smoke-Build + erster Test grün)."
    exit 0
fi

# llvm-cov export liefert JSON; daraus extrahieren wir die Total-Line-Coverage.
PROF=$(find .build -name 'default.profdata' 2>/dev/null | head -1)
if [ -z "$PROF" ]; then
    echo "✗ Keine Coverage-Daten gefunden — erst 'just test-coverage' laufen lassen."
    exit 1
fi

BUNDLE=$(find .build -name '*PackageTests.xctest' -type d 2>/dev/null | head -1)
if [ -n "$BUNDLE" ]; then
    BASE=$(basename "$BUNDLE" .xctest)
    BIN="$BUNDLE/Contents/MacOS/$BASE"
else
    BIN=$(find .build -type f -name '*PackageTests' -not -name '*.o' 2>/dev/null | head -1)
fi

if [ -z "$BIN" ] || [ ! -f "$BIN" ]; then
    echo "✗ xctest-Binary nicht gefunden."
    exit 1
fi

# llvm-cov report --summary-only liefert eine Zeile wie:
# TOTAL  123  45  63.41%  ...
# Wir parsen die letzte Zeile und extrahieren das erste Prozent-Feld
# (Line-Coverage = funktional die nützlichste Metrik für Unit-Tests).
REPORT=$(xcrun llvm-cov report "$BIN" \
    -instr-profile="$PROF" \
    -ignore-filename-regex='.build|Tests|\.swiftpm' 2>/dev/null)

# letzte Zeile ist TOTAL, daraus alle "XX.YY%"-Felder ziehen
PCT=$(echo "$REPORT" | tail -1 | grep -oE '[0-9]+\.[0-9]+%' | head -1 | tr -d '%')

if [ -z "$PCT" ]; then
    echo "✗ Coverage-Wert konnte nicht aus llvm-cov-Output extrahiert werden."
    echo "  Letzte Zeile war:"
    echo "$REPORT" | tail -3 | sed 's/^/    /'
    exit 1
fi

# Integer-Vergleich — wir nehmen die abgerundete Prozent-Zahl
PCT_INT=$(printf "%.0f" "$PCT")

echo "Phase $PHASE: Coverage = ${PCT}% (Gate: ≥ ${GATE}%)"

if [ "$PCT_INT" -lt "$GATE" ]; then
    echo
    echo "✗ Coverage-Gate VERFEHLT: ${PCT}% < ${GATE}%."
    echo "  Optionen:"
    echo "    1. Mehr Tests schreiben, bis die Schwelle erreicht ist."
    echo "    2. Phase um 'Test-Lücken schließen'-Tasks erweitern."
    echo "  NICHT erlaubt: Gate in UMSETZUNGSPLAN.md senken."
    exit 1
fi

echo "✓ Gate erreicht."
