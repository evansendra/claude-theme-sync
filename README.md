# Claude Theme Sync

Automatically sync [Claude Code](https://claude.ai/code) theme with macOS dark/light mode.

When you toggle macOS appearance, this daemon instantly updates Claude Code's theme setting so your next session matches your system theme.

## Installation

```bash
git clone https://github.com/alfredomtx/claude-theme-sync.git
cd claude-theme-sync
./install.sh
```

That's it! The daemon is now running and will start automatically on login.

## Requirements

- macOS 12.0+
- Xcode Command Line Tools (`xcode-select --install`)
- [Claude Code](https://claude.ai/code)

## How It Works

1. A lightweight Swift daemon listens to macOS theme change notifications
2. When the system theme changes, it updates `~/.claude.json` with the matching theme
3. All Claude Code sessions update in real-time

## Commands

```bash
# Check if running
launchctl list | grep claude-theme-sync

# View logs
tail -f ~/.claude/theme-sync/claude-theme-sync.log

# Restart
launchctl unload ~/Library/LaunchAgents/com.claude.theme-sync.plist
launchctl load ~/Library/LaunchAgents/com.claude.theme-sync.plist
```

## Uninstall

```bash
~/.claude/theme-sync/uninstall.sh
```

## Technical Details

Claude Code stores its theme preference in `~/.claude.json`:

```json
{
  "theme": "dark",
  ...
}
```

This daemon watches for `AppleInterfaceThemeChangedNotification` and updates that field when macOS appearance changes.

## License

MIT
