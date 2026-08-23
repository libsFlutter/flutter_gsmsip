# Understanding: Core Architecture

## Phase: EXITING

## Validated Understanding

The project implements **Clean Architecture** with well-defined layers:

### Layer Structure:
```
Presentation Layer (UI)
├── screens/          - App screens
├── widgets/          - Reusable widgets
├── providers/        - State providers
└── theme/            - Theme/styling

Domain Layer (Business Logic)
├── entities/         - Business entities
├── repositories/     - Repository interfaces
├── usecases/         - Use cases
└── exceptions/       - Business exceptions

Data Layer (Data & External)
├── datasources/      - Data sources (local/remote)
├── repositories/     - Repository implementations
├── models/           - Data models (DTOs)
└── services/         - External services

Core (Shared)
├── di/               - Dependency Injection (get_it)
├── error/            - Error handling (ErrorHandler)
├── utils/            - Utilities
└── constants/        - Constants
```

### Key Patterns Identified:

1. **Dependency Injection**: get_it with singleton/lazySingleton patterns
   - External deps: SharedPreferences, HTTP Client, Logger
   - Services: Storage, Network, Device, Permission, Theme, Localization, Security, Cache, API, Notification, Analytics
   - Repositories: Gateway, Settings, Analytics
   - Use Cases: Gateway, Settings, Analytics

2. **Error Handling**: Centralized ErrorHandler class
   - Global error capture via FlutterError.onError
   - Error logging to SharedPreferences (max 100 entries)
   - Analytics integration for error tracking
   - User-friendly error messages
   - ErrorBoundary widget for UI errors

3. **Architecture Principles**:
   - Dependency Inversion
   - Single Responsibility
   - Open/Closed
   - Interface Segregation
   - Dependency Injection

### Entry Point (main.dart):
- MultiProvider setup for services (GatewayService, SipService, SmsService, TelephonyService)
- Setup check screen with funny loading messages
- Material 3 theme with custom color scheme

## Sources

- `lib/core/architecture/app_architecture.dart` - Architecture documentation
- `lib/core/di/dependency_injection.dart` - DI configuration (extensive)
- `lib/core/error/error_handler.dart` - Error handling system
- `lib/main.dart` - App entry point

## Flow Created

**SDD**: `flows/sdd-core-architecture/`
- 01-requirements.md - Functional and non-functional requirements
- 02-specifications.md - Component specs, data flows, interfaces
- _status.md - DRAFT status

## Bubble Up

- Clean Architecture with 4 layers
- get_it for DI (extensive registration)
- Centralized error handling with analytics
- Provider for state management
- Material 3 theming
- SDD flow created (DRAFT)
