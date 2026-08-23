# SDD Index

Master index of all Spec-Driven Development flows.

## Active SDD Flows

| Name | Requirements | Specifications | Plan | Implementation | Status | Layer |
|------|--------------|----------------|------|----------------|--------|-------|
| sdd-account | ✓ | ✓ | ✗ | ✗ | DRAFT | L2 |
| sdd-activity-intents | ✓ | ✓ | ✗ | ✗ | DRAFT | L2 |
| sdd-android-implementation-sms | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-android-plugin | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-android-telecom-integration | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-build-system | ✓ | ✓ | ✗ | ✗ | DRAFT | L0 |
| sdd-call | ✓ | ✓ | ✗ | ✗ | DRAFT | L2 |
| sdd-call-model | ✓ | ✓ | ✗ | ✗ | DRAFT | L2 |
| sdd-core-architecture | ✓ | ✓ | ✗ | ✗ | DRAFT | L0 |
| sdd-dialer | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-endpoint | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-endpoint-2 | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-endpoint-3 | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-event-streaming | ✓ | ✓ | ✗ | ✗ | DRAFT | L0 |
| sdd-foreground-management | ✓ | ✓ | ✗ | ✗ | DRAFT | L2 |
| sdd-gateway-service | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-headless-service | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-monitoring | ✓ | ✓ | ✗ | ✗ | DRAFT | L0 |
| sdd-native-android-module | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-navigation | ✗ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-patch-management | ✓ | ✓ | ✗ | ✗ | DRAFT | L0 |
| sdd-release-workflow | ✓ | ✓ | ✗ | ✗ | DRAFT | L0 |
| sdd-sip | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-sip-core | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-sms-smpp | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-telephony | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-telephony-integration | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |
| sdd-ui-theming | ✗ | ✗ | ✗ | ✗ | EMPTY | L2 |
| sdd-unisim | ✓ | ✓ | ✗ | ✗ | DRAFT | L1 |

## Statistics

- **Total**: 29
- **Complete** (all docs): 0
- **In Progress**: 0
- **Draft** (requirements/specs only): 27
- **Empty** (no documents): 1
- **Missing Requirements**: 1 (sdd-navigation)

## By Layer

### Layer 0 (Infrastructure)

Core infrastructure and platform-level concerns.

| Name | Requirements | Specifications | Plan | Implementation |
|------|--------------|----------------|------|----------------|
| sdd-build-system | ✓ | ✓ | ✗ | ✗ |
| sdd-core-architecture | ✓ | ✓ | ✗ | ✗ |
| sdd-event-streaming | ✓ | ✓ | ✗ | ✗ |
| sdd-monitoring | ✓ | ✓ | ✗ | ✗ |
| sdd-patch-management | ✓ | ✓ | ✗ | ✗ |
| sdd-release-workflow | ✓ | ✓ | ✗ | ✗ |

**Count**: 6

### Layer 1 (Domain)

Domain services and telephony core functionality.

| Name | Requirements | Specifications | Plan | Implementation |
|------|--------------|----------------|------|----------------|
| sdd-android-implementation-sms | ✓ | ✓ | ✗ | ✗ |
| sdd-android-plugin | ✓ | ✓ | ✗ | ✗ |
| sdd-android-telecom-integration | ✓ | ✓ | ✗ | ✗ |
| sdd-dialer | ✓ | ✓ | ✗ | ✗ |
| sdd-endpoint | ✓ | ✓ | ✗ | ✗ |
| sdd-endpoint-2 | ✓ | ✓ | ✗ | ✗ |
| sdd-endpoint-3 | ✓ | ✓ | ✗ | ✗ |
| sdd-gateway-service | ✓ | ✓ | ✗ | ✗ |
| sdd-headless-service | ✓ | ✓ | ✗ | ✗ |
| sdd-native-android-module | ✓ | ✓ | ✗ | ✗ |
| sdd-navigation | ✗ | ✓ | ✗ | ✗ |
| sdd-sip | ✓ | ✓ | ✗ | ✗ |
| sdd-sip-core | ✓ | ✓ | ✗ | ✗ |
| sdd-sms-smpp | ✓ | ✓ | ✗ | ✗ |
| sdd-telephony | ✓ | ✓ | ✗ | ✗ |
| sdd-telephony-integration | ✓ | ✓ | ✗ | ✗ |
| sdd-unisim | ✓ | ✓ | ✗ | ✗ |

**Count**: 17

### Layer 2 (Features)

User-facing features and UI components.

| Name | Requirements | Specifications | Plan | Implementation |
|------|--------------|----------------|------|----------------|
| sdd-account | ✓ | ✓ | ✗ | ✗ |
| sdd-activity-intents | ✓ | ✓ | ✗ | ✗ |
| sdd-call | ✓ | ✓ | ✗ | ✗ |
| sdd-call-model | ✓ | ✓ | ✗ | ✗ |
| sdd-foreground-management | ✓ | ✓ | ✗ | ✗ |
| sdd-ui-theming | ✗ | ✗ | ✗ | ✗ |

**Count**: 6

## Dependencies

Based on flow names and architectural relationships.

| Flow | Requires | Enables |
|------|----------|---------|
| sdd-account | sdd-sip, sdd-endpoint | — |
| sdd-activity-intents | sdd-core-architecture | sdd-call, sdd-foreground-management |
| sdd-android-implementation-sms | sdd-android-plugin, sdd-telephony | — |
| sdd-android-plugin | sdd-core-architecture | sdd-android-implementation-sms, sdd-android-telecom-integration |
| sdd-android-telecom-integration | sdd-android-plugin, sdd-telephony | — |
| sdd-build-system | — | All flows |
| sdd-call | sdd-sip, sdd-endpoint, sdd-call-model | sdd-activity-intents |
| sdd-call-model | sdd-sip, sdd-endpoint | sdd-call |
| sdd-core-architecture | — | All flows |
| sdd-dialer | sdd-telephony, sdd-endpoint | — |
| sdd-endpoint | sdd-sip-core | sdd-call, sdd-dialer, sdd-gateway-service |
| sdd-endpoint-2 | sdd-sip-core | — |
| sdd-endpoint-3 | sdd-sip-core | — |
| sdd-event-streaming | sdd-core-architecture | sdd-monitoring |
| sdd-foreground-management | sdd-core-architecture, sdd-activity-intents | — |
| sdd-gateway-service | sdd-endpoint, sdd-sip | — |
| sdd-headless-service | sdd-core-architecture, sdd-android-plugin | — |
| sdd-monitoring | sdd-event-streaming, sdd-core-architecture | — |
| sdd-native-android-module | sdd-android-plugin, sdd-core-architecture | — |
| sdd-navigation | sdd-core-architecture | — |
| sdd-patch-management | sdd-release-workflow, sdd-build-system | — |
| sdd-release-workflow | sdd-build-system | sdd-patch-management |
| sdd-sip | sdd-sip-core | sdd-call, sdd-endpoint, sdd-gateway-service |
| sdd-sip-core | sdd-core-architecture | sdd-sip, sdd-endpoint |
| sdd-sms-smpp | sdd-telephony | — |
| sdd-telephony | sdd-core-architecture | sdd-dialer, sdd-android-telecom-integration |
| sdd-telephony-integration | sdd-telephony, sdd-android-plugin | — |
| sdd-ui-theming | sdd-core-architecture | — |
| sdd-unisim | sdd-sip, sdd-telephony | — |

## Notes

- **Status Inference**: Status is inferred from document completion since no `_status.md` files exist.
- **Document Legend**:
  - ✓ = Document exists
  - ✗ = Document missing
  - ⏳ = In progress (not currently used)
- **Layer Classification**:
  - **L0 (Infrastructure)**: Core architecture, event streaming, monitoring, build system, release workflow, patch management
  - **L1 (Domain)**: SIP, telephony, endpoint, gateway service, dialer, navigation, SMS, UniSIM, Android integration
  - **L2 (Features)**: Call, activity intents, foreground management, UI theming, account

## Warnings

- **sdd-navigation**: Missing `01-requirements.md` - only has specifications
- **sdd-ui-theming**: Empty directory - no documents created
- **No implementation logs**: None of the 29 flows have reached implementation phase
- **No plan documents**: None of the 29 flows have `03-plan.md`
- **No status files**: None of the 29 flows have `_status.md` for tracking progress

---

*Generated automatically. Update when SDD flows are added or modified.*
