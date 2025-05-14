# TapThatApp

<p align="center">
  <a href="https://github.com/neelshha/TapThatApp/releases/download/v1.0.0/TapThatApp.zip" style="text-decoration: none;">
    <span style="
      display: inline-flex;
      align-items: center;
      padding: 18px 36px;
      border-radius: 18px;
      background: linear-gradient(90deg, #6e48aa 0%, #9d50bb 100%);
      color: #fff;
      font-size: 1.4rem;
      font-weight: 600;
      box-shadow: 0 4px 24px rgba(110,72,170,0.18);
      transition: transform 0.1s, box-shadow 0.1s;
      border: none;
    ">
      <svg width="32" height="32" viewBox="0 0 24 24" fill="white" style="margin-right: 16px;">
        <path d="M16.365 1.43c0 1.14-.93 2.07-2.07 2.07-1.14 0-2.07-.93-2.07-2.07 0-1.14.93-2.07 2.07-2.07 1.14 0 2.07.93 2.07 2.07zm4.13 6.13c-.07-.07-1.44-1.41-3.13-1.41-1.24 0-2.01.59-2.98.59-.97 0-1.81-.58-2.97-.58-1.52 0-3.13 1.41-3.2 1.48-1.1 1.13-2.16 3.21-1.77 5.62.41 2.56 2.01 5.1 3.66 5.1.7 0 .97-.41 1.82-.41.85 0 1.09.41 1.82.41 1.65 0 3.19-2.47 3.6-5.01.13-.81.19-1.62.19-2.42 0-1.13-.09-2.01-.19-2.28zm-4.13 13.44c-.41 0-.82-.13-1.13-.38-.31-.25-.5-.6-.5-.98 0-.38.19-.73.5-.98.31-.25.72-.38 1.13-.38.41 0 .82.13 1.13.38.31.25.5.6.5.98 0 .38-.19.73-.5.98-.31.25-.72.38-1.13.38z"/>
      </svg>
      <span>Download for macOS</span>
    </span>
  </a>
</p>

A beautiful, modern macOS app for lightning-fast access to your favorite applications—right from your keyboard.


## ✨ Features

- **Radial App Ring:** Gorgeous, animated ring of your favorite apps, centered on your cursor with a single shortcut.
- **Live Preview:** Instantly see your app ring layout in the settings panel.
- **Customizable:** Choose icon size, ring radius, and which apps appear in your ring.
- **Modern UI:** Clean, dark, and distraction-free interface with beautiful animations and hover effects.
- **No Scrollbars:** Enjoy a seamless, scrollbar-free settings experience.
- **Quick Add/Remove:** Effortlessly add or remove apps from your ring.
- **Keyboard-Driven:** Launch your app ring with Option + Space from anywhere.
- **Accessibility:** Works across all spaces and most full-screen apps.
- **SwiftUI-Powered:** Built with the latest Apple technologies for performance and beauty.


## 🚀 Requirements

- macOS 13.0 or later (Sonoma recommended for best experience)
- Swift 5.5 or later


## 🛠️ Installation

1. **[⬇️ Download TapThatApp for macOS](https://github.com/neelshha/TapThatApp/releases/download/v1.0.0/TapThatApp.zip)**
2. Move the application to your Applications folder
3. Launch the application
4. Grant necessary permissions when prompted (Accessibility, if needed)
 

## 🧑‍💻 Usage

1. Open TapThatApp
2. Click the menu bar icon to open settings
3. Add your favorite apps to the ring
4. Adjust icon size and ring radius to your liking
5. Press <kbd>Option</kbd> + <kbd>Space</kbd> to summon the ring at your cursor—anywhere, anytime!
6. Hover for beautiful animations and launch apps instantly


## 🏗️ Development

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
  - `ContentView.swift` - Main view (radial ring logic)
  - `SettingsView.swift` - Settings interface (live preview, customization)
  - `PinnedAppLoader.swift` - Handles loading of pinned applications
  - `KeyEventHandling.swift` - Manages keyboard shortcuts
  - `OverlayPanel.swift` - Overlay panel implementation
  - `SettingsStore.swift` - Manages application settings
  - `LoginItemManager.swift` - Handles launch at login functionality
  - `LauncherController.swift` - Controls application launching
 

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
 

## 🙏 Acknowledgments

- Built with SwiftUI
- Uses modern macOS APIs for system integration 