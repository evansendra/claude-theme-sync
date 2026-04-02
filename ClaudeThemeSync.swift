import Foundation

class ClaudeThemeSync {
    private let configPath: String
    private var lastTheme: String?

    init() {
        self.configPath = NSString(string: "~/.claude.json").expandingTildeInPath
    }

    func start() {
        // Sync immediately on start
        lastTheme = isDarkModeEnabled() ? "dark" : "light"
        syncTheme()

        // Listen for theme changes via notification
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )

        // Poll every 5 seconds as fallback (notifications are unreliable under launchd)
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.pollTheme()
        }

        NSLog("Claude Theme Sync started. Listening for theme changes...")

        // Keep running
        RunLoop.current.run()
    }

    @objc private func handleThemeChange() {
        NSLog("Theme change detected via notification")
        let theme = isDarkModeEnabled() ? "dark" : "light"
        lastTheme = theme
        syncTheme()
    }

    private func pollTheme() {
        let theme = isDarkModeEnabled() ? "dark" : "light"
        if theme != lastTheme {
            NSLog("Theme change detected via poll")
            lastTheme = theme
            syncTheme()
        }
    }

    private func syncTheme() {
        let isDarkMode = isDarkModeEnabled()
        let theme = isDarkMode ? "dark" : "light"

        NSLog("Setting Claude Code theme to: \(theme)")

        if updateConfig(theme: theme) {
            NSLog("Successfully updated ~/.claude.json")
        } else {
            NSLog("Failed to update ~/.claude.json")
        }
    }

    private func isDarkModeEnabled() -> Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }

    private func updateConfig(theme: String) -> Bool {
        let fileManager = FileManager.default

        // Read existing config
        guard fileManager.fileExists(atPath: configPath),
              let data = fileManager.contents(atPath: configPath),
              var json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            NSLog("Error: Could not read ~/.claude.json")
            return false
        }

        // Check if theme is already correct
        if let currentTheme = json["theme"] as? String, currentTheme == theme {
            NSLog("Theme already set to \(theme), skipping update")
            return true
        }

        // Update theme
        json["theme"] = theme

        // Write back with pretty printing to preserve readability
        guard let updatedData = try? JSONSerialization.data(
            withJSONObject: json,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        ) else {
            NSLog("Error: Could not serialize JSON")
            return false
        }

        // Write atomically to prevent corruption
        do {
            try updatedData.write(to: URL(fileURLWithPath: configPath), options: .atomic)
            return true
        } catch {
            NSLog("Error writing config: \(error)")
            return false
        }
    }
}

// Main
let sync = ClaudeThemeSync()
sync.start()
