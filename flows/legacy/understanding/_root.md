# Understanding: Project Root

## Phase: EXPLORING

## Validated Understanding

**GOSTsimbox Android Gateway** - A Flutter application (v3.0.0) providing bidirectional bridge between GSM telephony and SIP/SMPP protocols.

### Key Characteristics:
- **License**: NativeMindNONC
- **SDK**: Flutter 3.8.1+
- **Architecture**: Clean Architecture (domain/data/presentation layers)
- **State Management**: Provider pattern
- **DI**: get_it for dependency injection

### Core Domains Identified:
1. **Gateway Service** - Core bidirectional routing logic (GSM ↔ SIP)
2. **Telephony Integration** - GSM call/SMS handling (permissions, device info)
3. **SIP Protocol** - SIP registration, call management
4. **SMPP Protocol** - SMS protocol handling (config via smpp_config.json)
5. **Cryptography** - GOST standards (crypto package)
6. **UI/Theming** - Dark theme, Material Design, humor/theme implementations
7. **Logging/Monitoring** - Real-time status, comprehensive logging

### Dependencies Analysis:
- State: provider, get_it, equatable, dartz (Result type)
- Storage: shared_preferences
- Network: http, connectivity_plus
- Security: crypto
- UI: flutter_svg, google_fonts, fl_chart
- Telephony: permission_handler, device_info_plus
- Background: workmanager
- Localization: flutter_localizations, intl

### Notes:
- SIP and Telephony Flutter plugins commented out (React Native dependencies issue)
- Legacy folder references suggest migration from React Native
- Multiple refactoring reports indicate ongoing architecture improvements

## Sources

- `pubspec.yaml` - Dependencies, version 3.0.0+300
- `README.md` - Feature documentation, architecture overview
- `lib/` - Clean architecture structure with domain/data/presentation separation

## Children

| Child | Status |
|-------|--------|
| project-metadata | DONE |
| core-architecture | PENDING |
| gateway-service | PENDING |
| telephony-integration | PENDING |
| sip-protocol | PENDING |
| smpp-protocol | PENDING |
| cryptography-domain | PENDING |
| ui-theming | PENDING |
| logging-monitoring | PENDING |
| testing-strategy | PENDING |

## Flow Recommendation

**Type**: SDD (primary) - Internal service logic for gateway
**Confidence**: high (validated by code structure)
**Rationale**: Backend-facing gateway service with clean architecture, no stakeholder-facing documentation needs

## Bubble Up

- Flutter v3.0.0, SDK 3.8.1+
- Clean Architecture (domain/data/presentation)
- GSM ↔ SIP bidirectional gateway
- SMPP protocol support
- GOST cryptography
- Provider + get_it for state/DI
- Extensive refactoring in progress
