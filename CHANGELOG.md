# Changelog

## 0.1.0 (2026-03-15)

### Initial Release

- **Core Functionality**
  - SIP voice calls via PJSIP native stack
  - SMS over SIP and GSM telephony
  - SMPP protocol support for SMS center connectivity
  - Multi-gateway support with multiple SIP accounts
  - Real-time event streaming for call and message states

- **Architecture**
  - Clean Architecture with Domain, Data, and Presentation layers
  - Flutter plugin with native Android Kotlin code
  - Service-based architecture with Android Intents
  - Dependency Injection ready (GetIt)

- **Domain Layer**
  - Entities: SipAccount, SipCall, GatewayConfig, GatewayStatus, CallRouting, etc.
  - Repositories: GatewayRepository, SipRepository, SmsRepository, etc.
  - Use Cases: Gateway use cases, SIP use cases, Settings use cases
  - Exceptions: Domain-specific exceptions

- **Data Layer**
  - Repository implementations
  - Service wrappers for native methods
  - Data sources (local storage, remote API)
  - Data models for serialization

- **Native Android Integration**
  - PJSIP native SIP stack integration
  - GSM telephony integration
  - SMPP client implementation
  - Headless service for background execution
  - Boot receiver for auto-start

- **Example App**
  - Complete working example application
  - Dashboard with status indicators
  - Call management screens
  - SMS and SMPP logs
  - Settings and configuration

### Technical Details

- **Dependencies**: dartz, equatable, logger, shared_preferences, http, permission_handler, get_it, intl, async
- **Minimum Requirements**: Flutter >=3.3.0, SDK ^3.10.8, Android API 21+
- **License**: NativeMindNONC
