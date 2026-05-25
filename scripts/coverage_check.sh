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

# Plattform-portabler llvm-cov-Aufruf: macOS via `xcrun llvm-cov`, Linux
# via blankes `llvm-cov` (üblicherweise aus dem llvm-Paket).
if command -v xcrun >/dev/null 2>&1; then
    LLVM_COV=(xcrun llvm-cov)
elif command -v llvm-cov >/dev/null 2>&1; then
    LLVM_COV=(llvm-cov)
else
    echo "✗ llvm-cov nicht gefunden — auf Linux: 'apt install llvm', auf macOS: Xcode-CLI-Tools."
    exit 1
fi

# Profile-Daten finden
PROF=$(find .build -name 'default.profdata' 2>/dev/null | head -1)
if [ -z "$PROF" ]; then
    echo "✗ Keine Coverage-Daten gefunden — erst 'just test-coverage' laufen lassen."
    exit 1
fi

# Test-Binary finden — auf macOS in einem .xctest-Bundle, auf Linux direkt
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

# llvm-cov report produziert eine TOTAL-Zeile mit drei (oder vier) Prozent-
# Werten:  Regions-%   Functions-%   Lines-%   [Branches-%]
# Wir wollen Line-Coverage = der DRITTE Prozent-Wert. (Regions ist die
# erste Spalte, die war im alten Code fälschlich genommen worden.)
REPORT=$("${LLVM_COV[@]}" report "$BIN" \
    -instr-profile="$PROF" \
    -ignore-filename-regex='.build|Tests|\.swiftpm' 2>/dev/null)

if [ -z "$REPORT" ]; then
    echo "✗ llvm-cov hat keinen Output produziert — Profile-Daten kaputt?"
    exit 1
fi

PCT=$(printf '%s\n' "$REPORT" | tail -1 | grep -oE '[0-9]+\.[0-9]+%' | sed -n '3p' | tr -d '%')

if [ -z "$PCT" ]; then
    echo "✗ Coverage-Wert konnte nicht aus llvm-cov-Output extrahiert werden."
    echo "  Letzte Zeile war:"
    printf '%s\n' "$REPORT" | tail -3 | sed 's/^/    /'
    exit 1
fi

# Floor statt Round — 49.99% darf NICHT das 50%-Gate erreichen.
# `${PCT%.*}` schneidet alles ab dem ersten Punkt ab (für 49.99 → "49").
PCT_INT="${PCT%.*}"

echo "Phase $PHASE: Line-Coverage = ${PCT}% (Gate: ≥ ${GATE}%)"

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
