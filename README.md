# igotuu 🛠️✨

A home-services mobile application crafted with Flutter (Material 3) where users find nearby verified workers (plumbers, electricians, carpenters, mechanics), compare ratings and prices, and describe their issues to an AI assistant using speech, voice recording, photo capture, or text.

---

## 🎨 Design System & Aesthetics

Built in alignment with the `taste-skill` anti-slop frontend guidelines (`DESIGN_VARIANCE: 7`, `MOTION_INTENSITY: 7`, `VISUAL_DENSITY: 4`) adapted specifically for mobile Flutter widgets:

- **Color Palette**:
  - `#FEFAF3`: Warm cream page background
  - `#F6E2E9`: Soft pink ambient glow
  - `#B8CFB3`: Light sage ambient glow & subtle borders
  - `#84A282`: Primary sage
  - `#3F5A3E`: Active states, icon accents, and primary contrast
  - `#26332A`: High-contrast dark charcoal text
- **Typography**:
  - **Logo**: Bold friendly script font (`Pacifico`)
  - **Headings**: `Sora`
  - **Body & Labels**: `DM Sans`
- **Glassmorphism**:
  - Built using `ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(sigma: ~18–22))`
  - White translucent fill at 25–40% opacity (`Colors.white.withValues(alpha: 0.32–0.38)`)
  - Layered 1px frosted white border at ~50–65% opacity
  - Soft multi-level ambient shadows (`offset: Offset(0, 8), blurRadius: 22`)
  - **Background Frosting**: Underneath the scrollable view, 3–4 large organic blurred gradient blobs (soft pink, light sage, primary sage) float and breathe gently, providing rich color backdrop so the glass surfaces appear truly frosted.

---

## 📱 Features

### 1. Animated Intro / First Launch (`lib/features/splash/`)
- Centered logo **"igu"** in bold script font fades and scales in on the cream background.
- It smoothly expands into **"igotuu"** (the middle letters `"ot"` and the trailing `"u"` seamlessly widen and fade in with an organic cubic easing curve—no visual jumps or clipping).
- Holds for ~0.5s.
- A sage-colored liquid wave sweeps upward across the screen via an animated cubic bezier path (`LiquidWaveClipper`), organically unveiling the Home page.
- Total animation duration is 3.2s (< 3.5s requirement) with a Hero transition settling the logo into the top-left of the Home header.

### 2. Home Screen (`lib/features/home/`)
1. **Header**:
   - Top-left: **"igotuu"** script logo with Hero continuity and location preview.
   - Top-right: Glass location-pin icon button (touch target >= 48x48dp).
   - Tapping opens a frosted bottom sheet displaying the saved address with options to:
     - **"Use current location"**: Requests GPS permissions gracefully, queries `geolocator`, and reverse-geocodes with `geocoding` into city/street.
     - **Manual input**: Type street/city in a styled frosted field.
     - **Save**: Persists to `shared_preferences` (`saved_user_address`) and updates the home state immediately.
2. **"Pick a service"**:
   - 2x2 grid of frosted glass panels: **Plumber**, **Electrician**, **Carpenter**, and **Mechanic**.
   - Includes trade icon badge, label, and trade subtitle.
   - Accessible "More" text button on the heading row.
3. **"Top rated near you"**:
   - Continuously auto-scrolling horizontal strip of 8 verified dummy providers.
   - Looping, smooth auto-scroll (~0.85 px/step) that automatically **pauses when the user touches or drags the strip** and resumes after a gentle pause.
   - Cards show initials avatar, name, trade, star rating with review counts (`★ 4.9 (142)`), hourly rate (`$45/hr`), distance (`0.8 km`), and a verified shield badge.
4. **AI Assist Card ("Find your problem?")**:
   - Frosted glass card with AI badge.
   - Multi-line text field (`"Tell us what's wrong..."`).
   - **Voice input & Language Chips**:
     - Toggle chips for **English**, **Tamil**, and **Hindi**.
     - Mic icon button: tap to start and stop speaking with an active pulsing recording animation.
     - Live speech-to-text transcript fills the text field (and remains editable).
     - Concurrently records audio using `record` to a local temp file.
     - After stopping, reveals an audio player bar with Play/Pause, time indicator, and a **Retake** button to discard and re-record.
   - **Animated Camera Icon**:
     - Animates in (scale + fade) **only after** the user has entered text or recorded voice.
     - Tapping opens the camera (`image_picker`) and displays an attached thumbnail preview with a Retake / Remove button.
   - **Submit Button**:
     - Disabled with subtle opacity when both text and voice are empty.
     - Enabled once there is text or voice. Tapping triggers a "coming soon" snackbar.

### 3. Floating Bottom Bar Shell (`lib/widgets/persistent_shell.dart`)
- Persistent shell widget wrapping pages using `Scaffold(extendBody: true)`.
- Floating frosted glass pill with radius 32, inset 16px from edges and bottom.
- Three navigation items: **Home** (active with sage highlight badge), **Bookings** (icon only, no-op), and **Profile** (icon only, no-op).
- Bottom scroll padding (`120dp`) ensures all content scrolls cleanly above the floating bar.

---

## 🏗️ Project Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # Configuration keys & language definitions
│   ├── services/
│   │   └── location_service.dart       # Geolocator, geocoding & SharedPreferences
│   └── theme/
│       ├── app_colors.dart             # Curated design palette & glass tokens
│       ├── app_theme.dart              # Material 3 theme configuration
│       └── app_typography.dart         # GoogleFonts (Sora, DM Sans, Pacifico)
├── features/
│   ├── splash/
│   │   └── presentation/
│   │       ├── splash_screen.dart      # "igu" -> "igotuu" expansion + liquid sweep
│   │       └── widgets/
│   │           └── liquid_wave_clipper.dart # Bezier liquid wave path
│   └── home/
│       ├── data/
│       │   └── dummy_providers.dart    # 8 verified service providers
│       └── presentation/
│           ├── home_screen.dart        # Main scrollable view with blobs
│           └── widgets/
│               ├── ai_assist_card.dart # Text, mic, speech, audio player, camera, submit
│               ├── home_header.dart    # Header with script logo & glass location button
│               ├── location_bottom_sheet.dart # GPS geolocation & manual address picker
│               ├── services_grid.dart  # 2x2 service panels + More button
│               └── top_rated_strip.dart# Continuous looping horizontal auto-scroller
├── widgets/
│   ├── blurred_background_blobs.dart   # Ambient animated gradient blobs
│   ├── frosted_glass.dart              # Core BackdropFilter glass container
│   ├── igotuu_logo.dart                # Script logo widget with Hero tag
│   └── persistent_shell.dart           # Floating glass pill bottom bar
└── main.dart                           # Entry point with edge-to-edge UI
```

---

## 🚀 Running the App

### Prerequisites
- Flutter SDK (stable, 3.24+ / 3.41+)
- Dart 3.5+ / 3.11+
- Android Studio / Xcode or VS Code / Antigravity IDE

### Run Steps
1. Navigate to the project root:
   ```bash
   cd "i got u"
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run static analysis (verified 0 issues):
   ```bash
   flutter analyze
   ```
4. Run tests:
   ```bash
   flutter test
   ```
5. Launch the app on a connected mobile device or emulator:
   ```bash
   # Android
   flutter run -d android

   # iOS
   flutter run -d ios

   # Or specify your connected device ID:
   flutter run
   ```

---

## 🔒 Permissions Configured

### Android (`android/app/src/main/AndroidManifest.xml`)
- `android.permission.INTERNET`
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.RECORD_AUDIO`
- `android.permission.CAMERA`
- `android.permission.BLUETOOTH` / `BLUETOOTH_CONNECT`

### iOS (`ios/Runner/Info.plist`)
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSSpeechRecognitionUsageDescription`
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

---

## 💡 Assumptions & Design Decisions
1. **Fallback for Simulator/Hardware Limitations**: On platforms or simulators without physical microphones or speech recognition services, microphone and speech requests are handled gracefully with clear user prompts rather than crashing.
2. **Infinite Looping Scroller**: The "Top rated near you" strip utilizes a large virtual buffer with modulo indexing and resets seamlessly to maintain fluid 60fps auto-scrolling that pauses instantly whenever the user's finger touches the screen.
3. **Logo Script Font**: Selected `Pacifico` from Google Fonts for its bold, warm, organic script letterforms that mirror the friendly personality of the "igu" / "igotuu" visual identity.
4. **State Simplicity**: Built using clean, idiomatic `StatefulWidget` / `setState` patterns without redundant bloated boilerplate, making it fast and easy to integrate with any backend or state provider in subsequent iterations.
