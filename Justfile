# Justfile — kanonische Befehle des Projekts.
# Installation: brew install just
# Aufruf: just <recipe>

# Default: zeigt die Liste verfügbarer Recipes
default:
    @just --list

# Setup nach git clone: alle Tools installieren + pre-commit-Hooks
bootstrap:
    @./scripts/bootstrap.sh

# Lokale Pre-commit-Hooks installieren
hooks:
    pre-commit install

# Pre-commit über alle Dateien laufen lassen
hooks-all:
    pre-commit run --all-files

# Lint-Check (swiftlint)
lint:
    swiftlint lint --strict

# Auto-Fix für lint-fixbare Verletzungen
lint-fix:
    swiftlint --fix

# Format-Check (swift-format aus Xcode-Toolchain)
format-check:
    xcrun swift-format lint --recursive Sources Tests

# Auto-Format
format:
    xcrun swift-format format --in-place --recursive Sources Tests

# Build (Debug)
build:
    swift build

# Build (Release, mit Optimierungen)
build-release:
    swift build -c release

# Tests ohne Coverage
test:
    swift test

# Tests mit Code-Coverage
test-coverage:
    swift test --enable-code-coverage
    @echo "Coverage profile: .build/debug/codecov/default.profdata"

# Coverage als Text-Report
coverage-report:
    @PROF=$(find .build -name 'default.profdata' | head -1); \
     BIN=$(find .build -name '*Tests' -type f -path '*.xctest/Contents/MacOS/*' | head -1); \
     [ -z "$BIN" ] && BIN=$(find .build -name '*Tests' -type f | head -1); \
     xcrun llvm-cov report "$BIN" -instr-profile="$PROF" -ignore-filename-regex='.build|Tests' || \
     echo "Erst 'just test-coverage' laufen lassen."

# Komplette Prüfkette — vor jedem Commit / nach jeder Änderung
check: lint format-check test
    @echo "✓ Alle Checks bestanden."

# Security-Scan: Secrets prüfen
security:
    gitleaks detect --source . --verbose --no-banner

# Dependency-Audit (für SPM)
audit:
    swift package audit-dependencies || echo "(swift package audit-dependencies steht erst ab Swift 5.10+ zur Verfügung)"

# Saubere Build-Artefakte löschen
clean:
    rm -rf .build .swiftpm
    swift package clean

# Vor dem Push — strenger Vollcheck
prepush: lint format-check test security
    @echo "✓ Bereit zum Push."

# Aktuelle Version aus Package.swift extrahieren (für Releases)
version:
    @grep -m1 'version = ' Sources/*/*.swift | sed 's/.*"\(.*\)".*/\1/' || echo "0.0.0"
