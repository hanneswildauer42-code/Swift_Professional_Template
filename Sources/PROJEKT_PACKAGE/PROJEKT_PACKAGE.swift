// Einstiegspunkt für PROJEKT_PACKAGE.
// Nach Phase 0: Datei umbenennen (oder löschen) und durch echte Module ersetzen.

import Foundation

public enum PROJEKT_PACKAGE {
    public static let version = "0.1.0"

    /// Smoke-Hello — wird beim Initialisieren eines neuen Projekts entfernt.
    public static func hello() -> String {
        "Hallo aus PROJEKT_PACKAGE v\(version)"
    }
}
