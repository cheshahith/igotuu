# igotuu 🛠️✨

A home-services mobile application crafted with Flutter (Material 3) featuring an on-demand "Nearby Workers" Google Maps flow (Rapido-style), interactive AI problem diagnostic assistant, and a persistent Bookings screen with a hand-drawn red pencil marked appointment calendar.

---

## 🎨 Design System & Aesthetics

Built in alignment with the `taste-skill` anti-slop frontend guidelines (`DESIGN_VARIANCE: 7`, `MOTION_INTENSITY: 7`, `VISUAL_DENSITY: 4`) adapted specifically for mobile Flutter widgets:

- **Curated Palette**:
  - `#FEFAF3`: Warm cream page background
  - `#F6E2E9`: Soft pink ambient glow
  - `#B8CFB3`: Light sage ambient glow & subtle borders
  - `#84A282`: Primary sage
  - `#3F5A3E`: Active states, icon accents, and primary contrast
  - `#26332A`: High-contrast dark charcoal text
  - `#D62828`: Hand-drawn red pencil circle stroke
- **Typography** (via Google Fonts):
  - **Logo**: Friendly script font (`Pacifico`)
  - **Headings**: `Sora`
  - **Body & Labels**: `DM Sans`
- **Glassmorphism & Depth**:
  - `FrostedGlass` container using `ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(sigma: ~18–24))`
  - Multi-stop translucent fills (`Colors.white.withValues(alpha: 0.32–0.45)`)
  - Crisp frosted boundary strokes (`Colors.white.withValues(alpha: 0.60–0.75)`)
  - Ambient elevation shadows with subtle tinted glow
  - Floating background gradient blobs (`BlurredBackgroundBlobs`) breathing gently beneath views

---

## 📱 Features & Flows

### 1. Animated Intro / First Launch (`lib/features/splash/`)
- Centered logo **"igu"** in bold script font fades and scales in on warm cream background.
- Expands seamlessly into **"igotuu"** with cubic easing.
- A sage-colored liquid wave sweeps upward (`LiquidWaveClipper`), organically unveiling the Home page with Hero continuity.

### 2. Home Screen (`lib/features/home/`)
1. **Header**:
   - Script logo + Glass location-pin button opening a frosted address bottom sheet (`geolocator` GPS + manual entry + `shared_preferences` persistence).
2. **AI Assist Card ("Find your problem?")**:
   - Integrated with **Firebase AI Logic (Gemini Developer API)** utilizing `gemini-3.8-flash`.
   - Multimodal diagnostic triage: accepts text, voice recordings (any language: English, Tamil, Tanglish, Hindi), and/or camera photos.
   - On-device image compression (max ~1024px, 80% JPEG) and 60-second audio recording cap.
   - Glassmorphism result view featuring urgency badge, diagnostic summary, safety advice card, "Find Workers Near Me" action, and manual trade picker fallback.
   - Dynamic follow-up loop if the model requires clarification.
3. **Pick a Service (2x2 Panels)**:
   - **Plumber**, **Electrician**, **Carpenter**, and **Mechanic**.
   - Tapping any service panel launches the **Nearby Workers** map flow for that specific trade.
4. **Top Rated Providers Strip**:
   - Smooth auto-scrolling horizontal carousel of verified providers that pauses when touched.

### 3. Nearby Workers Map Flow (Rapido-Style) (`lib/features/nearby/`)
A live Google Maps flow with 4 distinct states driven by `NearbyController`:

- **Screen State 1: Browsing**:
  - Full-screen Google Map centered on user's location with built-in blue dot and custom glass re-center button.
  - Floating glass back button and title chip (e.g., *"Electricians near you"*).
  - Runtime custom canvas `BitmapDescriptor` markers showing trade icon and star rating pill. Selected marker scales up.
  - Draggable frosted glass bottom sheet listing 6–8 workers within 0.3–3.0 km.
  - Card details: initials avatar, name, "Verified" badge, star rating, review count, VISIT FEE, hourly rate, distance, and ETA (~25 km/h).
  - Sort chips: **Nearest**, **Top rated**, **Lowest fee**.
  - Tapping a marker or card selects the worker, animates the camera to them, and reveals the "Request" button.
- **Screen State 2: Request & Waiting**:
  - Tapping "Request" displays *"Waiting for <name> to accept..."* with a pulsing animated concentric circle overlay around that worker's marker while other markers fade away.
  - Simulated worker decision: 3–6 seconds (80% accept, 20% decline with *"Busy with another job"* notice).
- **Screen State 3: Worker on the Way (Live Tracking)**:
  - On acceptance, shows *"<name> is on the way"* with real-time polyline route tracking toward the user.
  - Smooth interpolation of LatLng coordinates, bearing/heading marker rotation, and flat marker mode.
  - Dynamic camera framing bounds both the user and moving worker without jitter.
  - Sheet shows worker photo/avatar, live distance and ETA updating in real time, Call button (with phone dialer stub), and Cancel button.
  - **Debug Pause/Resume simulation button** (in debug builds) allows testing pausing/resuming live movement.
- **Screen State 4: Arrived**:
  - When worker reaches user's location (< 35m), route clears and sheet updates to *"<name> has arrived!"* with a "Start job" verification button.
  - **Automatic Booking Linkage**: When a request is accepted, a Pending booking is automatically scheduled into `BookingsRepository` so it appears in the Bookings tab.

### 4. Bookings Screen (`lib/features/bookings/`)
The second tab in the floating bottom navigation bar:
- **Date Header**: Glass card displaying today's date prominently (e.g., *"Tue, 13 Oct 2026"*), calendar icon, and animated chevron. Tapping toggles calendar expansion.
- **Expandable Month Calendar**:
  - Previous/Next arrows and horizontal swipe navigation between months.
  - Today is highlighted with a filled primary sage circle.
  - Selected date has an outlined highlight.
  - **Hand-drawn Red Pencil Circle**: Rendered via `RedPencilCirclePainter` using an imperfect, wobbly, overlapping ellipse stroke in `#D62828` (~1.8px round caps).
  - **Strict Marker Rule**: ONLY dates with at least one **COMPLETED** past booking receive the red circle. Dates with only pending bookings receive NO red circle.
  - Fully deterministic algorithm based on date seed so strokes never shift on rebuilds.
- **Appointments List**:
  - "Appointments" section heading with count badge and "Show all" chip to clear date filter.
  - Defaults to showing all bookings newest first; tapping any calendar date filters to that specific day.
  - Empty state with friendly illustration if no bookings exist for the selected date.
  - Frosted glass booking cards with provider avatar, name, trade, issue description, slot, hourly rate, and status chips (Completed = Sage checkmark; Pending = Warm clock badge).

### 5. Persistent Shell (`lib/widgets/persistent_shell.dart`)
- Houses `IndexedStack` preserving Home and Bookings states.
- Floating glass pill bottom bar with Home, Bookings, and Profile (no-op) tabs with 48dp+ touch targets.

---

## 🗺️ Google Maps API Key Setup Guide

The application uses `google_maps_flutter` and securely separates API keys from version control.

### Step 1: Create a Google Cloud Project
1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Click the project dropdown in the top bar and select **New Project**.
3. Name your project (e.g., `igotuu-maps`) and click **Create**.

### Step 2: Enable Billing
1. In the navigation menu, select **Billing**.
2. Link an active billing account to your project (Google Cloud requires billing enabled for Maps APIs; a generous free tier of $200 monthly credit is provided).

### Step 3: Enable the Required APIs
Navigate to **APIs & Services > Library** and enable the following:
- **Maps SDK for Android**
- **Maps SDK for iOS**
- **Directions API** (optional, for real driving route calculation)
- **Geocoding API** (for address lookup)

### Step 4: Generate and Restrict API Key
1. Go to **APIs & Services > Credentials**.
2. Click **+ Create Credentials > API Key**.
3. Copy the generated key.
4. Click **Edit API Key** to configure production restrictions:
   - **Android Restriction**:
     - Select *Android apps*.
     - Package name: `com.igotuu.igotuu`
     - SHA-1 certificate fingerprint:
       ```bash
       # Debug keystore SHA-1 (run in terminal):
       keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
       ```
   - **iOS Restriction**:
     - Select *iOS apps*.
     - Bundle identifier: `com.igotuu.igotuu`
   - **API Restrictions**: Limit key usage strictly to *Maps SDK for Android*, *Maps SDK for iOS*, and *Directions API*.

### Step 5: Android Setup (Git-Ignored)
1. In your project's `android/local.properties` file (which is in `.gitignore`), add:
   ```properties
   MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE
   ```
2. The Gradle build script in `android/app/build.gradle.kts` automatically reads `MAPS_API_KEY` from `local.properties` and injects it into `AndroidManifest.xml` via `manifestPlaceholders["MAPS_API_KEY"]`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="${MAPS_API_KEY}" />
   ```
   *No secret keys are hardcoded or checked into Git.*

### Step 6: iOS Setup (Git-Ignored)
1. In `ios/Runner/AppDelegate.swift`, the key is read securely from `Info.plist` or a git-ignored configuration:
   ```swift
   if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String, !apiKey.isEmpty {
     GMSServices.provideAPIKey(apiKey)
   }
   ```
2. When configuring for local iOS development, place your key in `ios/Runner/Info.plist` or an environment xcconfig file:
   ```xml
   <key>GoogleMapsAPIKey</key>
   <string>YOUR_GOOGLE_MAPS_API_KEY_HERE</string>
   ```

---

## 🧪 Architecture & Mock Simulation

To enable immediate testing without a backend, all data and routing operations are abstracted behind clean interfaces:

| Interface | Mock Implementation | Future Backend Replacement |
|---|---|---|
| `AiTriageService` | `MockTriageService` | `FirebaseAiTriageService` (Gemini Developer API via `firebase_ai`) |
| `WorkerRepository` | `MockWorkerRepository` | Firestore collection `workers/` filtered by geo-hash |
| `LiveLocationService` | `MockLiveLocationService` | Firestore snapshot listener `workers/{id}/location` or WebSocket |
| `RoutingService` | `MockRoutingService` | Google Directions API / Routes API decoder |
| `BookingsRepository` | `BookingsRepository` | Firestore collection `users/{uid}/bookings/` |

### How the Mock Simulation Works
1. **Dynamic Placement**: Workers are placed with random offsets 0.3–3.0 km around the user's real GPS position (or fallback coordinates).
2. **Deterministic Routing**: Curved bezier path waypoints are generated between the worker and the user.
3. **Live Speed & Heading**: The worker marker travels at ~25 km/h along the waypoints, calculating exact bearing for marker orientation.
4. **Interactive Controls**: In debug mode, a floating button lets you pause and resume worker movement to test interruptions and reconnects.

---

## 🤖 Firebase AI Logic & App Check Setup

The app integrates **Firebase AI Logic (`firebase_ai`)** using the Gemini Developer API with the featured model `gemini-3.8-flash`.

### 1. App Check Debug Token Registration (Required for Debug Builds)

Firebase App Check protects the Gemini API endpoint from unauthorized requests. In debug builds, the app registers `AndroidDebugProvider` and `AppleDebugProvider`.

Follow these steps to register your debug token in the Firebase Console:

1. **Run the App in Debug Mode**:
   ```bash
   flutter run -d android # or -d ios
   ```
2. **Retrieve the Debug Token from Terminal/Logcat**:
   - On **Android**, filter logcat output for `DebugAppCheckProvider`:
     ```text
     D/DebugAppCheckProvider: Enter this debug secret into the allow list in the Firebase Console for your project:
     XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
     ```
   - On **iOS**, filter Xcode console for `AppCheckDebugProvider`:
     ```text
     [FirebaseAppCheck][I-FAA001001] Firebase App Check Debug Token:
     XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
     ```
3. **Add Token to Firebase Console**:
   - Open [Firebase Console](https://console.firebase.google.com/) and navigate to your **`igotuu`** project.
   - Go to **Build** > **App Check** > **Apps** tab.
   - Click the three vertical dots (`⋮`) next to your registered Android or iOS app and select **Manage debug tokens**.
   - Click **Add debug token**, give it a name (e.g., `Pixel Emulator` or `Local Dev Mac`), paste the token UUID from step 2, and click **Save**.
4. **App Check Providers in Release**:
   - **Android**: Automatically switches to **Play Integrity**.
   - **iOS**: Automatically switches to **DeviceCheck** / **App Attest**.

---

### 2. Setting Up Budget Alerts (Cost Protection)

To avoid unexpected usage and track API expenditure:

1. Open the [Google Cloud Billing Console](https://console.cloud.google.com/billing).
2. Select the billing account linked to the **`igotuu`** project.
3. In the left navigation menu, click **Budgets & alerts**.
4. Click **Create budget**:
   - **Scope**: Select project `igotuu`.
   - **Services**: Select all services, or filter specifically to *Vertex AI / Gemini API*.
   - **Amount**: Set a target monthly budget (e.g., `₹500` or `$10.00`).
   - **Actions & Thresholds**: Configure alerts at `50%`, `90%`, and `100%` of budget.
   - **Notifications**: Check *Email alerts to billing admins and users*.
5. Click **Finish**. You will receive instant email notifications whenever consumption crosses the specified thresholds.

---

### 3. Safety, Privacy & Rate Limiting Architecture

- **Privacy Notice**: Displayed on first use informing the user that problem text, voice, or photo are sent to AI for diagnostic assistance.
- **Data Ephemerality**: Images and voice clips are never logged, stored, or persisted after the single inference call completes.
- **On-Device Optimization**: Camera attachments are compressed directly on-device to max ~1024px, 80% JPEG quality before network transit. Audio recordings are hard-capped at 60 seconds.
- **Local Throttling**: A sliding window limits requests to **5 requests per minute** and enforces single-flight concurrency to prevent accidental rapid double-taps.
- **20-Second Timeout & Resilient Fallback**: If the network times out, quota is exhausted, App Check fails, or the AI service is unreachable, a friendly error card provides an instant one-tap fallback to manually choose a trade.

---

## 🚀 Running the App & Tests

### 1. Static Analysis
Verify clean code quality (0 lints, 0 errors):
```bash
flutter analyze
```

### 2. Run Test Suite
Runs all unit and widget tests:
```bash
flutter test
```

### 3. Evaluate AI Triage Accuracy Benchmark
Run the dedicated test suite validating the AI triage model, JSON schema decoding, and 30 curated multilingual benchmark samples:
```bash
flutter test test/triage_test.dart
```

### 4. Launch App
```bash
# Android emulator or device
flutter run -d android

# iOS simulator or device
flutter run -d ios

# Web / Desktop preview (if enabled)
flutter run -d chrome
```
