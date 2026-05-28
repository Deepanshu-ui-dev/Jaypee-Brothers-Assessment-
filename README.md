# FinTrack 💰

A complete, production-ready Flutter personal finance tracker application
featuring a clean, minimal "zero-elevation" UI system. Built with modern Flutter
best practices.

## Features ✨

- **Zero-Elevation UI**: A premium, clean visual design with no shadows or
  excessive cards.
- **Firebase Authentication**: Full email/pass login, register, and forgot
  password flow.
- **Firestore Database**: Real-time syncing and offline persistence for
  transactions and categories.
- **Riverpod State Management**: Robust, boilerplate-reduced dependency and
  state management.
- **Analytics & Charts**: Detailed category breakdown and 6-month visual
  spending bar charts via `fl_chart`.
- **Categorization**: Manage both income and expense categories with custom
  icons and tint colors.
- **CSV Export**: Export all transactions to CSV for external use.
- **Biometric Lock Support**: UI placeholders ready for `local_auth`
  integration.
- **Dark Mode Support**: Complete theming tokens implemented for both light and
  dark aesthetics.

## Tech Stack 🛠️

- **Framework**: Flutter 3.x
- **State Management**: `flutter_riverpod`
- **Routing**: `go_router`
- **Backend**: Firebase (Auth & Firestore)
- **Charts**: `fl_chart`
- **Typography**: `google_fonts` (Plus Jakarta Sans & DM Mono)

## Setup & Execution 🚀

1. **Firebase Configuration**:
   - Create a project in the
     [Firebase Console](https://console.firebase.google.com/).
   - Enable **Authentication** (Email/Password).
   - Enable **Firestore Database** and update security rules.
   - Add Android/iOS apps to the Firebase project and download
     `google-services.json` / `GoogleService-Info.plist` respectively.

2. **Environment Variables**:
   - Copy `.env.example` to `.env` and fill in your specific application IDs or
     keys if required (most Firebase config is handled by the `google-services`
     files natively).

3. **Run Application**:
   ```bash
   flutter pub get
   flutter run
   ```

## Architecture 🏗️

The project uses a clean layer-by-layer structure:

- `lib/core/` - Constants, design system, extensions, utilities.
- `lib/data/` - Models, Repositories (Firestore), Services.
- `lib/providers/` - Riverpod state notifiers and providers.
- `lib/presentation/` - UI screens, structured by feature (auth, dashboard,
  transactions, etc.).

## Note

Ensure the correct packages are pre-installed and internet connection is active
on initial test device run to download Google Fonts properly.
