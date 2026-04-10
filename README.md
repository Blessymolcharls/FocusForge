# BlessyForge 🔥

A personal productivity and goal-tracking Flutter app designed for **Blessy** — a CS student preparing for IBM placements, GATE exam, coding practice, and college assignments.

---

## Features

| Screen | Description |
|--------|-------------|
| **Dashboard** | Today's tasks, goal progress bars, XP streak, upcoming deadlines |
| **Task Planner** | Add/complete tasks with category, due date, reminder & duration |
| **Goals** | Create long-term goals (IBM, GATE, Coding, Assignments) with progress |
| **Coding Tracker** | Track LeetCode / CodeChef / HackerRank problems with weekly chart |
| **Assignment Manager** | Manage college assignments with deadlines and status |
| **Settings** | Configure daily notifications, view XP level, test notifications |

### Gamification
- +20 XP — Solve a coding problem
- +30 XP — Complete a study task
- +40 XP — Submit an assignment
- Levels: Beginner -> Learner -> Scholar -> Expert -> Master
- Daily streak tracked automatically

### Notifications (Schedulable)
- 7:00 AM — "Blessy, time to study for GATE!"
- 10:00 AM — "Solve 2 coding problems today!"
- 6:00 PM — "Stay consistent and forge your future!"
- 9:00 PM — Evening review reminder

---

## Project Structure

lib/
|-- main.dart                        (Entry point & bottom navigation)
|-- models/
|   |-- task_model.dart
|   |-- goal_model.dart
|   |-- assignment_model.dart
|   +-- coding_progress_model.dart
|-- services/
|   |-- storage_service.dart         (Hive CRUD + XP/streak + sample data seeder)
|   +-- notification_service.dart    (flutter_local_notifications)
|-- screens/
|   |-- dashboard_screen.dart
|   |-- task_planner_screen.dart
|   |-- goals_screen.dart
|   |-- coding_tracker_screen.dart
|   |-- assignment_manager_screen.dart
|   +-- settings_screen.dart
+-- widgets/
    |-- app_theme.dart               (Dark theme + category colours)
    +-- common_widgets.dart          (Shared UI components)

---

## Installation

### Prerequisites
- Flutter SDK >= 3.11.0
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)

### Steps

1. Install dependencies:
   flutter pub get

2. Run on Android:
   flutter run

3. Build release APK:
   flutter build apk --release
   APK: build/app/outputs/flutter-apk/app-release.apk

---

## Dependencies

| Package                      | Purpose                          |
|------------------------------|----------------------------------|
| hive + hive_flutter          | Local NoSQL database             |
| flutter_local_notifications  | Scheduled & daily reminders      |
| timezone                     | Timezone-aware scheduling        |
| fl_chart                     | Weekly activity bar chart        |
| percent_indicator            | Linear & circular progress bars  |
| intl                         | Date formatting                  |
| uuid                         | Unique IDs for records           |
| shared_preferences           | XP and streak persistence        |

---

## Sample Data (auto-seeded on first launch)

- 4 tasks across all categories
- 4 goals: IBM, GATE, LeetCode 150, Semester Assignments
- 4 college assignments with upcoming deadlines
- 3 coding platforms: LeetCode 45/150, CodeChef 30/100, HackerRank 52/100
- Starting XP: 350 | Streak: 5 days

---

Forge your future, Blessy! 🚀
