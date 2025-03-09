## [1.0.0] - 2025-03-08

### 🚀 New Features
- **Initial release** of **VLC Player X** 🎉
- Integration of **VLC-based video playback** with support for local and network video sources.
- **Apple TV-inspired UI** with customizable controls.
- **Gesture-based interactions** for video navigation and volume adjustment.
- Customizable controls: **play/pause, seek, volume, progress bar**.

## [1.1.0] - 2025-03-10

### 🛠 Fixes & Improvements
- **Fixed volume control stability** by improving event handling.
- **Resolved drag-end detection issue** using `addPostFrameCallback` to ensure proper execution of `onChangeEnd`.
- **Optimized volume change logic** to prevent unnecessary state updates.
- **Refactored volume event listeners** to reduce redundant calls and improve UI responsiveness.