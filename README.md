# TapThatApp

<p align="center">
  <a href="https://github.com/neelshha/TapThatApp/tree/main/TapThatApp.app/Contents">
    <img src="https://img.shields.io/badge/Download%20TapThatApp-%20%E2%86%93%20-blueviolet?style=for-the-badge&logo=apple" alt="Download TapThatApp"/>
  </a>
</p>

A beautiful, modern macOS app for lightning-fast access to your favorite applications—right from your keyboard.

---

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

---

## 🚀 Requirements

- macOS 13.0 or later (Sonoma recommended for best experience)
- Swift 5.5 or later

---

## 🛠️ Installation

1. **[⬇️ Download TapThatApp](https://github.com/neelshha/TapThatApp/tree/main/TapThatApp.app/Contents)**
2. Move the application to your Applications folder
3. Launch the application
4. Grant necessary permissions when prompted (Accessibility, if needed)

---

## 🧑‍💻 Usage

1. Open TapThatApp
2. Click the menu bar icon to open settings
3. Add your favorite apps to the ring
4. Adjust icon size and ring radius to your liking
5. Press <kbd>Option</kbd> + <kbd>Space</kbd> to summon the ring at your cursor—anywhere, anytime!
6. Hover for beautiful animations and launch apps instantly

---

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

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- Built with SwiftUI
- Uses modern macOS APIs for system integration 