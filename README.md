# QuestLogic

A **skill-swap social platform** built with Flutter and Supabase. Users post what they can teach and what they want to learn, browse other users' profiles, and chat to arrange skill exchanges.

> NUS Orbital 2026 Project

---

## Features

| Tab | Description |
|-----|-------------|
| **Home** | Feed of recent skill-swap posts from the community |
| **Post** | Create a new post � title, description, skill offered & wanted |
| **Browse** | Search and browse user profiles; tap to view their posts |
| **Quests** | All community quests + your own quests in a tabbed view |
| **Chat** | Real-time conversations with other users via Supabase Realtime |
| **Profile** | Edit your username, bio, skills to teach/learn, and avatar |

---

## Tech Stack

- **Flutter** (Dart) cross-platform mobile UI
- **Supabase** PostgreSQL database, Auth, Storage, and Realtime subscriptions
- **image_picker** avatar photo upload

---

## Project Structure

```
lib/
+-- main.dart                  # App entry, Supabase init, AuthGate
+-- screens/
    +-- main_screen.dart       # Bottom navigation (6 tabs)
    +-- auth_screen.dart       # Sign in / Sign up
    +-- profile_screen.dart    # Profile editing + avatar upload
    +-- home/
       +-- home_screen.dart
       +-- widgets/post_card.dart
    +-- browse/
       +-- browse_screen.dart
       +-- user_profile_screen.dart
       +-- widgets/
           +-- skill_chip.dart
           +-- profile_card.dart
           +-- user_post_card.dart
    +-- post/
       +-- post_screen.dart
    +-- quests/
       +-- quests_screen.dart
       +-- widgets/
           +-- quest_tag.dart
           +-- quest_card.dart
           +-- quest_list.dart
    +-- chat/
        +-- chat_screen.dart
        +-- chat_detail_screen.dart
        +-- widgets/
            +-- conversation_tile.dart
            +-- message_bubble.dart
            +-- message_input_bar.dart
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.12
- Android Studio / Android SDK (for emulator or physical device)
- A [Supabase](https://supabase.com) project with the schema above

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/weijun72/QuestLogic.git
   cd QuestLogic
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**

   Open `lib/main.dart` and replace the URL and anon key with your own project values:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

4. **Run on emulator or device**
   ```bash
   flutter run
   ```
   If you have multiple devices connected, Flutter will prompt you to choose. To target a specific device, first list available devices:
   ```bash
   flutter devices
   ```
   Then run with the device ID shown:
   ```bash
   flutter run -d <device-id>
   ```

---

## Running on Android

### Android Emulator

1. Open **Android Studio → Virtual Device Manager**
2. Create a new AVD (e.g. Pixel 7, API 33+) with GPU set to **Hardware (GLES 2.0)** and at least **4096 MB RAM**
3. Start the emulator, then:
   ```bash
   flutter devices          # find your emulator's device ID
   flutter run -d <device-id>
   ```
   The first emulator started typically gets the ID `emulator-5554`, but always confirm with `flutter devices`.

### Physical Android Device

1. Enable **Developer Options** and **USB Debugging** on your device
2. Connect via USB, then:
   ```bash
   flutter devices          # confirm your device appears
   flutter run -d <device-id>
   ```

---

## Running on iOS (macOS only)

> iOS builds require a Mac with Xcode installed.

### Prerequisites

- macOS with **Xcode 15+** installed (from the App Store)
- Xcode command-line tools: `xcode-select --install`
- CocoaPods: `sudo gem install cocoapods`

### iOS Simulator

1. Open Xcode → **Window → Devices and Simulators** and start a simulator, or use:
   ```bash
   open -a Simulator
   ```
2. Then run:
   ```bash
   flutter devices          # find your simulator's device ID
   flutter run -d <device-id>
   ```

### Physical iPhone/iPad

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set your **Team** under **Signing & Capabilities**
3. Connect your device, trust the Mac on the device, then:
   ```bash
   flutter devices
   flutter run -d <device-id>
   ```