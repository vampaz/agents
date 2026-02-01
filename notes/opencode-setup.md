# OpenCode autostart with basic auth (macOS)

## Confirmed binary path

- Homebrew (Apple Silicon): `/opt/homebrew/bin/opencode`
- Homebrew (Intel): `/usr/local/bin/opencode`
- npm global (default): `/usr/local/bin/opencode`
- npm global (custom prefix): `~/.npm-global/bin/opencode`
- pnpm global: `~/.local/share/pnpm/opencode`
- bun global: `~/.bun/bin/opencode`
- curl installer: `~/.opencode/bin/opencode`

## Launch agent file

Create `~/Library/LaunchAgents/com.opencode.server.plist` with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.opencode.server</string>

    <key>ProgramArguments</key>
    <array>
      <string>/Users/carlosrodrigues/.nvm/versions/node/v24.11.1/bin/opencode</string>
      <string>serve</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
      <key>OPENCODE_SERVER_USERNAME</key>
      <string>your-username</string>
      <key>OPENCODE_SERVER_PASSWORD</key>
      <string>your-password</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/opencode-serve.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/opencode-serve.err</string>
  </dict>
</plist>
```

## Load and manage

Load now:

```sh
launchctl load ~/Library/LaunchAgents/com.opencode.server.plist
```

Stop it later:

```sh
launchctl unload ~/Library/LaunchAgents/com.opencode.server.plist
```

Check logs:

```sh
tail -f /tmp/opencode-serve.log
```

## Remove

Stop it:

```sh
launchctl unload ~/Library/LaunchAgents/com.opencode.server.plist
```

Delete the plist:

```sh
rm ~/Library/LaunchAgents/com.opencode.server.plist
```

Optional cleanup:

```sh
launchctl remove com.opencode.server
```

If you used `launchctl bootstrap` instead of `load`:

```sh
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.opencode.server.plist
```
