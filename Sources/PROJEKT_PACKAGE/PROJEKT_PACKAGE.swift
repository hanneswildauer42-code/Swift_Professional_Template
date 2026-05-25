// Einstiegspunkt für PROJEKT_PACKAGE.
// Nach Phase 0: Datei umbenennen (oder löschen) und durch echte Module ersetzen.
//
// Hinweis zum Lint: Solange dieses File noch unter Sources/PROJEKT_PACKAGE/
// liegt, ist es per `.swiftlint.yml` vom Lint ausgeschlossen (Platzhalter
// enthält einen Unterstrich, der gegen die type_name-Default-Regel verstößt).
// Nach `./scripts/rename_package.sh` heißt der Pfad z. B. Sources/DemoTool/
// und wird normal gelintet.

import Foundation

public enum PROJEKT_PACKAGE {
    public static let version = "0.1.0"

    /// Smoke-Hello — wird beim Initialisieren eines neuen Projekts entfernt.
    public static func hello() -> String {
        "Hallo aus PROJEKT_PACKAGE v\(version)"
    }
}
