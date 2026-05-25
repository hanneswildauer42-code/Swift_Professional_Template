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
    @./scripts/coverage_report.sh

# Coverage gegen Phasen-Gate prüfen — bricht mit Exit ≠ 0 ab,
# wenn die Total-Line-Coverage unter der Schwelle liegt.
# Aufruf: just coverage-check PHASE=2
coverage-check PHASE="0":
    @./scripts/coverage_check.sh {{PHASE}}

# Komplette Prüfkette — vor jedem Commit / nach jeder Änderung
check: lint format-check test
    @echo "✓ Alle Checks bestanden."

# Security-Scan: Secrets prüfen
security:
    gitleaks detect --source . --verbose --no-banner

# Dependency-Audit über OSV (Open Source Vulnerabilities).
# Setzt `osv-scanner` voraus (brew install osv-scanner).
audit:
    @if command -v osv-scanner >/dev/null 2>&1; then \
        osv-scanner scan source --lockfile Package.resolved 2>/dev/null \
          || osv-scanner scan source .; \
    else \
        echo "✗ osv-scanner nicht installiert."; \
        echo "  brew install osv-scanner"; \
        exit 1; \
    fi

# Saubere Build-Artefakte löschen
clean:
    rm -rf .build .swiftpm
    swift package clean

# Vor dem Push — strenger Vollcheck
prepush: lint format-check test security
    @echo "✓ Bereit zum Push."

# Aktuelle Version aus Sources/<Package>/*.swift extrahieren (für Releases).
# Sucht nach `static let version = "X.Y.Z"`-Konvention.
# Fällt auf 0.0.0 zurück, wenn nichts Passendes gefunden wird.
version:
    @VER=$(grep -hoE 'version = "[0-9]+\.[0-9]+\.[0-9]+"' Sources/*/*.swift 2>/dev/null \
             | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'); \
     echo "${VER:-0.0.0}"
