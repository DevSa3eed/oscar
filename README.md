# Duty App 📱

A Flutter application for managing duty assignments and compliance tracking, built with clean architecture principles.

## Features

### 🔐 Authentication
- Role-based login system (Supervisor/HOD)
- Demo credentials provided for testing
- Secure authentication flow

### 👨‍💼 Supervisor Features
- **Duty List**: View all duty persons assigned for the day
- **Duty Check Form**: Record compliance status for each person
- **Real-time Status**: Track present/absent, phone usage, vest compliance, and punctuality
- **Notes**: Add additional observations

### 👨‍💻 HOD (Head of Department) Features
- **Dashboard**: Overview of daily duty performance
- **Compliance Metrics**: Track total persons, issues, and compliance percentage
- **Issue Management**: View and manage reported issues
- **Reminder System**: Send email reminders to non-compliant persons
- **Reports**: Generate daily, weekly, and monthly reports

## Architecture

The app follows **Clean Architecture** principles with:

- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: Controllers, pages, and widgets
- **Core Layer**: Constants, themes, utilities, and routing

### Tech Stack

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **AutoRoute**: Navigation
- **Freezed**: Data classes and immutability
- **GetIt**: Dependency injection
- **Firebase**: Backend services (configurable)

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project (optional for demo)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd oscar
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Demo Credentials

The app includes demo authentication for testing:

**Supervisor Account:**
- Email: `supervisor@demo.com`
- Password: `password123`

**HOD Account:**
- Email: `hod@demo.com`
- Password: `password123`

## Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── errors/            # Error handling
│   ├── routes/            # Navigation routes
│   ├── theme/             # App theming
│   └── utils/             # Utility functions
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── duty/              # Duty management
│   └── reports/           # Reporting
├── shared/                # Shared services
│   └── services/          # Dependency injection
└── main.dart             # App entry point
```

## Features Overview

### Supervisor Workflow

1. **Login** with supervisor credentials
2. **View Duty List** showing all assigned persons
3. **Check Each Person** using the duty check form
4. **Record Status** for presence, phone usage, vest compliance, and punctuality
5. **Add Notes** for additional observations

### HOD Workflow

1. **Login** with HOD credentials
2. **View Dashboard** with compliance overview
3. **Review Issues** reported by supervisors
4. **Send Reminders** to non-compliant persons
5. **Generate Reports** for different time periods

## Design Principles

- **Clean Architecture**: Separation of concerns
- **SOLID Principles**: Maintainable and extensible code
- **Repository Pattern**: Data abstraction
- **Dependency Injection**: Loose coupling
- **State Management**: Reactive UI updates
- **Type Safety**: Strong typing throughout

## Customization

### Adding New Duty Types

1. Update `AppConstants` with new duty types
2. Add to sample data in `SampleData` class
3. Update UI components as needed

### Modifying UI Theme

1. Edit `AppTheme` class in `core/theme/app_theme.dart`
2. Update color schemes and styling
3. Apply consistent theming across the app

### Adding New Features

1. Create new feature module following the existing structure
2. Implement domain, data, and presentation layers
3. Register dependencies in `dependency_injection.dart`
4. Add routes in `app_router.dart`

## Testing

The app is structured to support comprehensive testing:

- **Unit Tests**: Test individual components
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows

## Contributing

1. Follow the existing code structure and patterns
2. Maintain clean architecture principles
3. Write comprehensive tests
4. Update documentation as needed

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Built with ❤️ using Flutter and Clean Architecture**