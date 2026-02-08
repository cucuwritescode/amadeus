# basic pitch server

the server is already running in the cloud. only these changes need to be made prior to building the app.

## 1. update Info.plist
replace the contents of `Info.plist` with:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSBonjourServices</key>
	<array>
		<string></string>
		<string>_http._tcp</string>
	</array>
	<key>NSMicrophoneUsageDescription</key>
	<string>Amadeus needs microphone access to record audio for chord analysis. Record songs and discover their chord progressions in real-time.</string>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
</dict>
</plist>
```

## 2. update the server url in two files
- `BasicPitchConfig.swift` line 60, should look like:
  ```swift
  static let defaultServerURL = "http://139.59.188.51:8000"
  ```
- `SettingsView.swift` line 27, should look like:
  ```swift
  @AppStorage("serverURL") private var serverURL = "http://139.59.188.51:8000"
  ```

## 3. build and run
build and run the app on your device. it should connect to the cloud server automatically.
