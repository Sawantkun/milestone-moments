# MilestoneMoments

A modern, premium **Parenting & Child Development Tracker** built with Flutter — targeting Android and iOS with a polished, minimal UI, smooth animations, and a full feature set for tracking every precious moment of your child's growth.

---

## Screenshots

> Onboarding → Auth → Dashboard → Timeline → Health Charts → Reminders → PDF Report

---

## Features

| Category | Feature |
|---|---|
| **Onboarding** | 4-page animated flow with smooth page indicator |
| **Auth** | Sign up, Login, Forgot Password (mock, local) |
| **Dashboard** | Bottom nav with 5 tabs + nested screens |
| **Children** | Add & manage multiple children profiles |
| **Milestones** | Timeline of developmental milestones (motor, language, social, cognitive) |
| **Health** | Height & weight growth charts with fl_chart |
| **Mood Logs** | Daily emoji mood tracker with notes & activity tags |
| **AI Activities** | Age-appropriate activity suggestions (mocked, grouped by age range) |
| **Reminders** | Doctor visits & vaccination reminders with local notifications |
| **PDF Reports** | Shareable A4 summary report (child overview, milestones, health, reminders) |
| **Themes** | Light & dark mode toggle |
| **Persistence** | Full local storage via SharedPreferences (no backend required) |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider (`ChangeNotifier`) |
| Local Storage | `shared_preferences` |
| Charts | `fl_chart ^0.69` |
| Notifications | `flutter_local_notifications ^18` |
| PDF Generation | `pdf` + `printing` |
| Animations | `flutter_animate ^4.5` |
| Typography | `google_fonts` — Poppins |
| Page Indicator | `smooth_page_indicator` |
| IDs | `uuid` |

---

## Project Structure

```
lib/
├── main.dart                   # Entry point — MultiProvider + service init
├── app.dart                    # MaterialApp, named routes, theme consumer
│
├── theme/
│   ├── app_colors.dart         # Color palette + gradients
│   └── app_theme.dart          # Light & dark ThemeData (Poppins)
│
├── models/
│   ├── user_model.dart
│   ├── child_model.dart        # Computed age helpers
│   ├── milestone_model.dart
│   ├── health_record_model.dart
│   ├── mood_entry_model.dart
│   ├── activity_model.dart
│   └── reminder_model.dart
│
├── services/
│   ├── auth_service.dart       # Mock auth via SharedPreferences
│   ├── storage_service.dart    # CRUD + sample data seeding
│   ├── notification_service.dart
│   ├── ai_service.dart         # Age-grouped activity suggestions
│   └── pdf_service.dart        # A4 PDF report builder
│
├── state/
│   ├── auth_provider.dart
│   ├── child_provider.dart
│   └── theme_provider.dart
│
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart   # Bottom nav shell
│   │   ├── home_tab.dart
│   │   ├── timeline_tab.dart
│   │   ├── health_tab.dart
│   │   ├── reminders_tab.dart
│   │   └── more_tab.dart
│   └── child/
│       ├── add_child_screen.dart
│       ├── child_detail_screen.dart
│       ├── mood_log_screen.dart
│       ├── activities_screen.dart
│       ├── add_milestone_screen.dart
│       └── reports_screen.dart
│
└── widgets/
    ├── glassmorphic_card.dart
    ├── gradient_button.dart
    ├── milestone_card.dart
    ├── mood_selector.dart
    ├── child_card.dart
    ├── section_header.dart
    ├── custom_app_bar.dart
    ├── reminder_card.dart
    ├── activity_card.dart
    └── empty_state.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.4.0`
- Dart SDK `>=3.4.0`
- Xcode (for iOS) or Android Studio (for Android)

### Run

```bash
git clone <repo-url>
cd bloomnest

flutter pub get
flutter run
```

### Test Account

The app seeds a demo account and two children on first launch. Use these credentials:

```
Email:    test@example.com
Password: password123
```

Or register a new account on the sign-up screen — all data is stored locally.

### Sample Data

On first launch, two children are automatically created:

| Child | DOB | Gender |
|---|---|---|
| Emma | 2024-03-15 | Female |
| Noah | 2025-10-01 | Male |

Both come pre-loaded with milestones, health records, mood entries, and upcoming reminders.

---

## Platform Setup

### Android — Notification Permissions

Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

And inside `<application>`:

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
  </intent-filter>
</receiver>
```

### iOS — Notification Permissions

No manual setup needed — the plugin requests permission at runtime on first notification use.

For production, add to `ios/Runner/Info.plist` if needed:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>MilestoneMoments uses notifications to remind you about vaccinations and appointments.</string>
```

---

## Named Routes

| Route | Screen |
|---|---|
| `/splash` | Splash + routing logic |
| `/onboarding` | 4-page onboarding |
| `/login` | Login |
| `/signup` | Sign up |
| `/forgot-password` | Password reset |
| `/dashboard` | Main dashboard (bottom nav) |
| `/add-child` | Add / edit child |
| `/child-detail` | Child profile + tabs |
| `/mood-log` | Daily mood logger |
| `/activities` | AI activity suggestions |
| `/add-milestone` | Add milestone |
| `/reports` | PDF report screen |

---

## Design System

- **Primary:** `#7B61FF` (purple)
- **Accent:** `#FF6B9D` (pink)
- **Secondary:** `#00BFA5` (teal)
- **Font:** Poppins (Google Fonts)
- **Cards:** Glassmorphic — semi-transparent with border, adapts to light/dark
- **Animations:** `flutter_animate` staggered entrance animations, Hero transitions on child cards

---

## Roadmap

- [ ] Cloud sync (Firebase / Supabase)
- [ ] Photo attachments for milestones
- [ ] Growth percentile overlays (WHO standards)
- [ ] Multi-language support
- [ ] Pediatrician sharing via deep link
- [ ] Apple Health / Google Fit integration

---

## License

MIT
