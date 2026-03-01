# ClearDay Calendar App

A modern, feature-rich Flutter calendar application designed with a robust **feature-based BLoC architecture** for scalability, clarity, and ease of use.

## ✨ Core Features

- **🗓️ Multiple Perspectives**: Beautifully designed Year, Month, Week, Day, and Agenda views.
- **📅 Event Management**: Full CRUD operations for personal and device-synced events.
- **🔄 Smart Recurrence**: Flexible support for daily, weekly, monthly, and yearly recurring patterns.
- **🗑️ Advanced Recycle Bin**: Secure deletion with a secondary recycle bin allowing for event restoration or 30-day auto-purge.
- **😊 Mood Tracking**: Log and visualize your daily mood directly within the calendar.
- **🔌 Device Integration**: Seamlessly sync with system calendars, contacts (birthdays), and local notifications.
- **🎨 Personalized Experience**: Dynamic dark mode support, adjustable font scales, and customizable first day of the week.

## 🏗️ Technical Architecture

The application has been refactored from a legacy provider model to a professional **Feature-Based BLoC Architecture**, ensuring strict separation of concerns and modularity.

### Directory Structure
Each feature follows a consistent layered pattern:
- `lib/features/{feature_name}/data/`:
    - `models/`: Immutable data structures and JSON serialization.
    - `repositories/`: Abstract interfaces for data operations.
    - `repositories_impl/`: Concrete implementations (SharedPreferences, Device APIs).
- `lib/features/{feature_name}/presentation/`:
    - `bloc/`: Business Logic Components (Events, States, Blocs).
    - `screens/`: Primary UI views.
    - `widgets/`: Feature-specific reusable UI components.

### Key State Management (BLoC)
- **CalendarBloc**: Managed event lifecycle and device synchronization.
- **DateBloc**: Synchronizes the global selected date across all independent views.
- **RecycleBinBloc**: Handles the specific lifecycle of deleted and restored events.
- **SettingsBloc**: Manages global preferences, aesthetics, and onboarding.
- **MoodBloc**: Tracks and persists daily emotional wellbeing data.

## 🛠️ Technology Stack

- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) with [equatable](https://pub.dev/packages/equatable) for efficient updates.
- **Data Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences) for local storage.
- **Device Connectivity**: [device_calendar](https://pub.dev/packages/device_calendar) for system integration.
- **Utilities**: [intl](https://pub.dev/packages/intl) for localization and date formatting.

## 🚀 Getting Started

1.  **Dependencies**: Run `flutter pub get` to install all required packages.
2.  **Run**: Execute `flutter run` to launch the application.

## 🔧 Recent Refactoring Highlights

- **Architecture Migration**: Transitioned the entire state management layer from Riverpod to BLoC.
- **Feature Modularization**: Consolidated fragmented files into cohesive feature modules (`calendar`, `mood`, `settings`).
- **Performance Optimization**: Implemented `Equatable` for state comparison to minimize unnecessary builds.
- **UI/UX Consistency**: Standardized typography, fixed month-view font scaling, and improved event visibility across all views.
