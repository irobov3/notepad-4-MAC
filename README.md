# Notepad++ for Mac 🦎

<p align="center">
  <img src="Resources/AppIcon.png" width="128" height="128" alt="Notepad++ for Mac Logo" />
</p>

<p align="center">
  <strong>An authentic, ultra-lightweight, native macOS text editor inspired by Notepad++.</strong><br>
  Built with 100% native Swift & AppKit for Apple Silicon (macOS 14.0+).
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014.0+-black?style=flat&logo=apple" alt="macOS" />
  <img src="https://img.shields.io/badge/Architecture-Apple%20Silicon%20(arm64)-orange?style=flat" alt="Apple Silicon" />
  <img src="https://img.shields.io/badge/Language-Swift%205.10-F05138?style=flat&logo=swift" alt="Swift" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat" alt="License" />
</p>

---

## 📸 Screenshot

<p align="center">
  <img src="Resources/screenshot.png" width="90%" alt="Notepad++ for Mac Screenshot" />
</p>

---

## ✨ Key Features

- **🚀 100% Native AppKit**: Instant launch time (< 0.2s), low RAM consumption (~40MB), zero Electron / web framework overhead.
- **🦎 Authentic Notepad++ Aesthetics**: Classic Green Chameleon mascot, Notepad squircle icon, and Scintilla-inspired color schemes (Light Classic & Dark Mode).
- **🎨 Multi-Language Syntax Highlighting**:
  - C / C++
  - Python
  - JavaScript / TypeScript
  - HTML / XML
  - JSON
  - Markdown
  - SQL
  - Swift
  - Shell / Bash
- **📑 Tabbed Multi-Document Interface**:
  - Classic Notepad++ status indicator dot (**Red** = modified/unsaved, **Blue** = clean/saved).
  - Quick tab closing, "+" new tab button, and keyboard navigation.
- **📏 Accurate Line Gutter Ruler**:
  - Synchronized line numbers perfectly aligned with text fragments.
- **🔍 Collapsible Find & Replace Bar (`⌘F`)**:
  - Find Next, Find Prev, Replace, Replace All, and Count occurrences.
  - Match case, whole word, and regular expression toggles.
- **📊 Real-Time Status Telemetry**:
  - `Ln`, `Col`, `Pos`, total `lines`, total `length`.
  - Line ending format (`Unix (LF)` / `Windows (CR LF)`).
  - File encoding (`UTF-8`).
  - Active syntax language and `INS` mode indicator.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `⌘N` | New Document / Tab |
| `⌘O` | Open File(s)... |
| `⌘S` | Save Active Document |
| `⇧⌘S` | Save All Documents |
| `⌘W` | Close Current Tab |
| `⌘F` | Toggle Find & Replace Bar |
| `⌘+` / `⌘-` | Zoom In / Zoom Out Font Size |
| `⌘Z` / `⇧⌘Z` | Undo / Redo |

---

## 📦 Installation

1. Download the latest **`Notepad++ for Mac.dmg`** from [Releases](https://github.com/irobov3/notepad-4-MAC/releases).
2. Double-click the DMG and drag **`Notepad++ for Mac`** into your **`Applications`** folder.
3. *First Launch*: Right-click `Notepad++ for Mac` in Applications and choose **Open** (required once for ad-hoc signed community builds on macOS).

---

## 🛠️ Building from Source

### Prerequisites
- macOS 14.0 (Sonoma) or newer on Apple Silicon (`arm64`).
- Xcode Command Line Tools (`xcode-select --install`).

### Build & Run
```bash
# Clone the repository
git clone https://github.com/irobov3/notepad-4-MAC.git
cd notepad-4-MAC

# Compile and install to /Applications/NotepadMac.app
./build.sh

# Create the distributable installer DMG
./package_dmg.sh
```

---

## 📜 Credits & License

- **Developer**: Developed by [iRoBo](https://github.com/irobov3).
- **Inspiration**: Inspired by [Notepad++](https://notepad-plus-plus.org) by Don Ho.
- **License**: Released under the [MIT License](LICENSE).
