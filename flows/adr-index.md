# ADR Index

Master index of all Architecture Decision Records.

## Active ADRs

| # | Name | Title | Type | Status | Created | Decided | File |
|---|------|-------|------|--------|---------|---------|------|
| 001 | activity-result | Activity Result Handling for setDefaultDialer | enabling | DRAFT | 2026-03-04 | - | flows/adr-001-activity-result/ |
| 001 | clean-architecture | Clean Architecture | constraining | DRAFT | 2026-03-03 | - | flows/adr-001-clean-architecture/ |
| 001 | docker-builds | Docker-Based Build System | enabling | DRAFT | 2026-03-04 | - | flows/adr-001-docker-builds/ |
| 001 | eventemitter-architecture | EventEmitter Architecture | enabling | DRAFT | 2026-03-04 | - | flows/adr-001-eventemitter-architecture/ |
| 001 | pjsip-native | PjSIP Native Integration | constraining | DRAFT | 2026-03-04 | - | flows/adr-001-pjsip-native/ |
| 001 | service-architecture | Service-Based Architecture with Android Intents | enabling | DRAFT | 2026-03-04 | - | flows/adr-001-service-architecture/ |
| 002 | dependency-injection | Dependency Injection (get_it) | enabling | DRAFT | 2026-03-03 | - | flows/adr-002-dependency-injection/ |
| 002 | dual-endpoint-strategy | Dual Endpoint Strategy (PJSIP vs Android Telecom) | enabling | DRAFT | 2026-03-04 | - | flows/adr-002-dual-endpoint-strategy/ |
| 002 | event-channel | EventChannel for Real-Time Event Streaming | enabling | DRAFT | 2026-03-04 | - | flows/adr-002-event-channel/ |
| 002 | eventemitter | EventEmitter Pattern for State Management | enabling | DRAFT | 2026-03-04 | - | flows/adr-002-eventemitter/ |
| 002 | version-isolation | Version Isolation Strategy (PJSIP versions) | constraining | DRAFT | 2026-03-04 | - | flows/adr-002-version-isolation/ |
| 003 | json-serialization | JSON Serialization for Android Intent Extras | enabling | DRAFT | 2026-03-04 | - | flows/adr-003-json-serialization/ |
| 003 | promise-callback-pattern | Promise Callback Pattern | constraining | DRAFT | 2026-03-04 | - | flows/adr-003-promise-callback-pattern/ |
| 003 | promise-pattern | Promise Wrapper Around Native Callbacks | constraining | DRAFT | 2026-03-04 | - | flows/adr-003-promise-pattern/ |
| 003 | state-management | State Management (Provider) | enabling | DRAFT | 2026-03-03 | - | flows/adr-003-state-management/ |
| 004 | callback-pattern | Sequential Callback ID Registration Pattern | enabling | DRAFT | 2026-03-04 | - | flows/adr-004-callback-pattern/ |
| 004 | error-handling | Error Handling (Centralized) | enabling | DRAFT | 2026-03-03 | - | flows/adr-004-error-handling/ |
| 004 | immutable-models | Immutable Data Models (JavaScript) | constraining | DRAFT | 2026-03-04 | - | flows/adr-004-immutable-models/ |
| 005 | immutable-models | Immutable Dart Data Models | enabling | DRAFT | 2026-03-04 | - | flows/adr-005-immutable-models/ |
| 005 | service-orchestration | Service Orchestration (GatewayService) | constraining | DRAFT | 2026-03-03 | - | flows/adr-005-service-orchestration/ |
| 005 | video-components | Native Video Component Architecture | enabling | DRAFT | 2026-03-04 | - | flows/adr-005-video-components/ |
| 006 | duration-calculation | Real-Time Call Duration Calculation | enabling | DRAFT | 2026-03-04 | - | flows/adr-006-duration-calculation/ |

### Types
- **constraining** (ограничивающий) - selects from options, closes alternatives
- **enabling** (расширяющий) - adds new capabilities, expands scope
- **pending** (ожидающий принятия решения) - decision deferred, awaiting more information

## Statistics

- **Total**: 22
- **Approved**: 0
- **Review**: 0
- **Draft**: 22
- **Rejected**: 0
- **Superseded**: 0

### By Type
- **Enabling**: 14
- **Constraining**: 8
- **Pending**: 0

## Categories

### Architecture
- ADR 001: Clean Architecture - Four-layer Clean Architecture implementation
- ADR 001: Service-Based Architecture with Android Intents - Service architecture for SIP operations
- ADR 001: PjSIP Native Integration - Native PjSIP library wrapping strategy
- ADR 005: Service Orchestration - GatewayService as central orchestrator
- ADR 005: Native Video Component Architecture - Native video rendering components

### State Management & Events
- ADR 001: EventEmitter Architecture - Two-layer event system (DeviceEventEmitter + EventEmitter)
- ADR 002: EventEmitter Pattern for State Management - Node.js EventEmitter for SIP events
- ADR 002: EventChannel for Real-Time Event Streaming - Flutter EventChannel for push-based events
- ADR 003: State Management (Provider) - Provider for UI state with service streams

### Data & Models
- ADR 003: JSON Serialization for Android Intent Extras - DTO pattern with JSON for Intent data
- ADR 004: Immutable Data Models (JavaScript) - Classes with getters, no setters
- ADR 005: Immutable Dart Data Models - Final fields with fromMap/toMap pattern
- ADR 006: Real-Time Call Duration Calculation - Construction time offset pattern

### Async Patterns
- ADR 003: Promise Callback Pattern - (successful, data) tuple wrapped in Promises
- ADR 003: Promise Wrapper Around Native Callbacks - Promise wrapper for native callbacks
- ADR 004: Sequential Callback ID Registration Pattern - Async operation tracking with IDs

### Error Handling
- ADR 004: Error Handling (Centralized) - Centralized ErrorHandler with categories

### Dependency Management
- ADR 002: Dependency Injection (get_it) - get_it as DI framework

### Build & Versioning
- ADR 001: Docker-Based Build System - Docker containers for reproducible PJSIP builds
- ADR 002: Version Isolation Strategy (PJSIP versions) - Separate directories per PJSIP version

### Platform Integration
- ADR 001: Activity Result Handling for setDefaultDialer - Android activity result handling
- ADR 002: Dual Endpoint Strategy (PJSIP vs Android Telecom) - Two Endpoint implementations

## Relationships

### Dependencies

| ADR | Depends On | Relationship |
|-----|------------|--------------|
| 002 (dependency-injection) | 001 (clean-architecture) | DI supports Clean Architecture layers |
| 003 (state-management) | 001 (clean-architecture) | State management supports layer separation |
| 003 (state-management) | 002 (dependency-injection) | Uses get_it for service registration |
| 004 (error-handling) | 001 (clean-architecture) | Error handling in core layer |
| 005 (service-orchestration) | 001 (clean-architecture) | Orchestrates services across layers |
| 005 (service-orchestration) | 002 (dependency-injection) | Uses DI for service instantiation |
| 005 (service-orchestration) | 003 (state-management) | Uses streams for state coordination |
| 002 (event-channel) | 001 (service-architecture) | Events originate from service |
| 003 (json-serialization) | 001 (service-architecture) | Required for Intent data transfer |
| 004 (callback-pattern) | 001 (service-architecture) | Tracks async operations in service |
| 006 (duration-calculation) | 005 (immutable-models) | Uses immutable _constructionTime |

### Supersedes
- (none yet)

### Conflicts
- (none identified)

### Related Clusters

**Clean Architecture Cluster (Flutter):**
- ADR 001: Clean Architecture
- ADR 002: Dependency Injection
- ADR 003: State Management
- ADR 004: Error Handling
- ADR 005: Service Orchestration
- ADR 005: Immutable Dart Data Models

**React Native SIP Cluster:**
- ADR 001: PjSIP Native Integration
- ADR 001: EventEmitter Architecture
- ADR 002: EventEmitter Pattern
- ADR 002: Dual Endpoint Strategy
- ADR 003: Promise Callback Pattern
- ADR 003: Promise Pattern
- ADR 004: Immutable Models (JavaScript)
- ADR 005: Video Components
- ADR 001: Activity Result Handling

**Build System Cluster:**
- ADR 001: Docker Builds
- ADR 002: Version Isolation

**Flutter-SIP Plugin Cluster:**
- ADR 001: Service Architecture
- ADR 002: Event Channel
- ADR 003: JSON Serialization
- ADR 004: Callback Pattern
- ADR 006: Duration Calculation

---

## Index Maintenance

When creating/updating ADRs:
1. Add entry to table above
2. Update statistics
3. Add to relevant category
4. Note any relationships

**Last updated**: 2026-03-05
**Next ADR number**: 7 (or new 001 for new sequence)

## Notes

### Multiple ADR-001/002/etc. Numbers

This index contains multiple ADRs with the same number (e.g., six different "ADR 001" entries). This indicates:
- Different documentation sequences/projects within the codebase
- Legacy analysis generated ADRs from multiple sources
- Consider consolidating or renumbering for clarity

### Sources

ADRs in this index were generated from:
- Legacy analysis (`/legacy` command) - 2026-03-03 to 2026-03-04
- Manual documentation

### Warnings

- All ADRs are in DRAFT status - none have been formally approved
- Some ADRs may be duplicates or overlapping (e.g., promise-callback-pattern vs promise-pattern)
- Numbering conflicts should be resolved for production use
