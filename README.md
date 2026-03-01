# ClearDay Calendar App

A modern, feature-rich Flutter calendar application designed for clarity and ease of use.

## Features

- **Multiple Views**: Year, Month, Week, Day, and Agenda views.
- **Event Management**: Easily add, edit, and delete events.
- **Recurrence Support**: Flexible event recurrence patterns.
- **Device Sync**: Integration with device calendars.
- **Dark Mode**: Beautiful dark theme support.
- **Customizable**: Adjustable font sizes and first day of week.

## Architecture

The project follows a clean architecture pattern using **Riverpod** for state management:

- `lib/providers/`: State management and business logic.
- `lib/models/`: Data models (Events, Settings).
- `lib/screens/`: UI Screens.
- `lib/services/`: External services (Notifications, Holidays).
- `lib/widgets/`: Reusable UI components.
- `lib/theme/`: App-wide styling and themes.

## Getting Started

1.  **Dependencies**: Run `flutter pub get` to install required packages.
2.  **Run**: Execute `flutter run` to start the application on your connected device or emulator.

## Recent UI/UX Improvements

- **Standardized Typography**: Fixed inconsistent font sizes across calendar views.
- **Enhanced Event Visibility**: Month view cells now support vertical scrolling to ensure all events are visible.
- **Refined Styling**: Improved text wrapping and alignment for better readability.
