# Crypto Insight Dashboard

A Flutter mini-app that serves as a dashboard for cryptocurrency insights. The app fetches data from the CoinGecko API and displays it in a clean, user-friendly interface. It includes features like pagination, search, detailed coin views, and data persistence.

## Features

- **Dashboard Screen**:
    - Displays a list of cryptocurrencies with their name, symbol, current price, and 24-hour price change.
    - Pull-to-refresh to fetch the latest data.
    - Infinite scrolling with pagination to load more coins.
    - Search functionality to filter coins by name or symbol.
    - A "Recently Viewed" section to quickly access coins.
- **Details Screen**:
    - Shows detailed information for a selected coin, including market cap, rank, and 24h high/low.
    - Displays a historical price chart (sparkline).
    - Calculates and shows a "Volatility Score" based on 7-day and 30-day price changes, with a color indicator.
- **Summary Screen**:
    - After viewing three or more unique coins, a summary screen becomes accessible.
    - It shows the average price of viewed coins, the best and worst performers, and a list of all viewed coins.
- **Data Persistence**:
    - Uses `Hive` to persist the list of viewed coins locally on the device.

## Architecture & Tech Stack

- **State Management**: `flutter_bloc` for predictable state management.
- **API Handling**: `dio` for making HTTP requests to the CoinGecko API.
- **Local Storage**: `hive` for fast and efficient local database storage.
- **UI & UX**:
    - Built with Material 3 components.
    - `fl_chart` for displaying beautiful and interactive charts.
    - `cached_network_image` for efficient image loading.
    - `google_fonts` for custom typography (Open Sans).
- **Architecture**: Follows a clean, modular folder structure (data, repository, logic, ui).

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

- Flutter SDK
- Dart SDK
- An IDE like Android Studio or VS Code with the Flutter plugin.

### Installation

1.  Clone the repository:
    ```sh
    git clone <repository-url>
    ```
2.  Navigate to the project directory:
    ```sh
    cd practical_keyai
    ```
3.  Install dependencies:
    ```sh
    flutter pub get
    ```

### Running the Application

1.  Make sure you have a device connected or an emulator running.
2.  Run the app:
    ```sh
    flutter run
    ```
**Note for Windows Users**: If you encounter an error about symlink support, you need to enable Developer Mode in your system settings.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
