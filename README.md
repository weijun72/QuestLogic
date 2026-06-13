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

## Supabase Schema

### `profiles`
| Column | Type |
|--------|------|
| id | uuid (FK ? auth.users) |
| username | text |
| bio | text |
| skillsToTeach | text |
| skillsToLearn | text |
| avatar_url | text |

### `posts`
| Column | Type |
|--------|------|
| id | uuid |
| user_id | uuid (FK ? profiles) |
| title | text |
| description | text |
| skill_offered | text |
| skill_wanted | text |
| created_at | timestamptz |

### `messages`
| Column | Type |
|--------|------|
| id | uuid |
| sender_id | uuid (FK ? profiles) |
| receiver_id | uuid (FK ? profiles) |
| content | text |
| created_at | timestamptz |

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

### Android Emulator (recommended)

Create a **Pixel 7** AVD in Android Studio with:
- API Level 33+
- GPU: Hardware (GLES 2.0)
- RAM: 4096 MB

```bash
flutter run -d emulator-5554
```

---

## License

MIT
