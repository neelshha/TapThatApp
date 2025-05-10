# TapThatApp

A macOS application that provides quick access to your favorite applications through keyboard shortcuts and an overlay panel.

## Features

- Quick access to pinned applications
- Customizable keyboard shortcuts
- Overlay panel for easy navigation
- Launch at login option
- Modern SwiftUI interface

## Requirements

- macOS 11.0 or later
- Xcode 13.0 or later (for development)
- Swift 5.5 or later

## Installation

1. Download the latest release from the releases page
2. Move the application to your Applications folder
3. Launch the application
4. Grant necessary permissions when prompted

## Usage

1. Open TapThatApp
2. Configure your pinned applications in the settings
3. Set up your preferred keyboard shortcuts
4. Use the configured shortcuts to quickly access your applications

## Development

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/neelshha/TapThatApp.git
```

2. Open the project in Xcode:
```bash
cd TapThatApp
open TapThatApp.xcodeproj
```

3. Build and run the project (⌘R)

### Project Structure

- `TapThatApp/` - Main application directory
  - `TapThatAppApp.swift` - Application entry point
  - `ContentView.swift` - Main view
  - `SettingsView.swift` - Settings interface
  - `PinnedAppLoader.swift` - Handles loading of pinned applications
  - `KeyEventHandling.swift` - Manages keyboard shortcuts
  - `OverlayPanel.swift` - Overlay panel implementation
  - `SettingsStore.swift` - Manages application settings
  - `LoginItemManager.swift` - Handles launch at login functionality
  - `LauncherController.swift` - Controls application launching

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with SwiftUI
- Uses modern macOS APIs for system integration 