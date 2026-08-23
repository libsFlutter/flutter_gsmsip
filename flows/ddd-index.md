# DDD Index

Master index of all Document-Driven Development flows.

## Active DDD Flows

| Name | Requirements | Specifications | Plan | Implementation | Status | Layer | Stakeholders |
|------|--------------|----------------|------|----------------|--------|-------|--------------|
| ddd-001-voip-calling | ✓ (stakeholder) | ✗ | ✗ | ✗ | DRAFT | L2 | Enterprise, Remote Workers, Customer Support, Healthcare, Field Services |
| ddd-imei-modification | ✓ | ✗ | ✗ | ✗ | DRAFT | L1 | Service Centers, Corporate Clients, Technical Specialists |

## Statistics

- **Total**: 2
- **Complete** (all docs): 0
- **In Progress**: 0
- **Draft** (requirements only): 2
- **Empty** (no documents): 0

## By Stakeholder Type

### Enterprise
- ddd-001-voip-calling

### Remote Workers
- ddd-001-voip-calling

### Customer Support
- ddd-001-voip-calling

### Healthcare
- ddd-001-voip-calling

### Field Services
- ddd-001-voip-calling

### Service Centers
- ddd-imei-modification

### Corporate Clients
- ddd-imei-modification

### Technical Specialists
- ddd-imei-modification

## By Layer

### Layer 1 (Domain)

Domain services and device-level functionality.

| Name | Requirements | Specifications | Plan | Implementation |
|------|--------------|----------------|------|----------------|
| ddd-imei-modification | ✓ | ✗ | ✗ | ✗ |

**Count**: 1

### Layer 2 (Features)

User-facing features and business capabilities.

| Name | Requirements | Specifications | Plan | Implementation |
|------|--------------|----------------|------|----------------|
| ddd-001-voip-calling | ✓ | ✗ | ✗ | ✗ |

**Count**: 1

## Related SDD

| DDD Flow | Related SDD | Relationship |
|----------|-------------|--------------|
| ddd-001-voip-calling | sdd-endpoint | Implements VoIP endpoint API |
| ddd-001-voip-calling | sdd-sip | Implements SIP protocol layer |
| ddd-001-voip-calling | sdd-call | Implements call management |
| ddd-001-voip-calling | sdd-call-model | Implements call state model |
| ddd-imei-modification | sdd-android-plugin | Device interaction via plugin |

## Flow Details

### ddd-001-voip-calling

**Purpose**: VoIP (Voice over IP) calling feature for enterprise mobile communication.

**Business Value**:
- Build custom mobile SIP clients for iOS and Android
- Leverage existing PBX phone systems
- Provide employees with business phone numbers on personal devices
- Enable video calling capabilities
- Support remote work scenarios
- Reduce mobile communication costs

**Key Requirements**:
- SR-1: Make Outgoing Calls
- SR-2: Receive Incoming Calls
- SR-3: Video Calling
- SR-4: Call Management (hold, transfer, conference)
- SR-5: Account Configuration
- SR-6: Network Resilience
- SR-7: Battery Efficiency
- SR-8: Security & Privacy (HIPAA, GDPR compliance)

**Success Metrics**:
- Call Setup Time: < 3 seconds
- Call Success Rate: > 95%
- Audio Quality (MOS): > 4.0
- Video Frame Rate: > 15 FPS
- Battery Drain (idle): < 5%/hour

**Documents**:
- `01-stakeholder-requirements.md` - Business and stakeholder requirements

---

### ddd-imei-modification

**Purpose**: IMEI modification module for Huawei and Qtech devices (ГОСТ СИМБОКС).

**Business Value**:
- Safe IMEI modification for supported devices
- Restore IMEI after firmware reset
- Support for device board replacement
- Testing and development scenarios

**Key Requirements**:
- BR-IMEI-001: IMEI Modification (read, change, restore, backup, validate)
- BR-IMEI-002: Device Support (Huawei E3372, E5573, B525; Qtech QMP-M1-N IP68)
- BR-IMEI-003: Legal Compliance (legitimate use cases only)
- FR-IMEI-001: Device Detection
- FR-IMEI-002: IMEI Reading (AT commands)
- FR-IMEI-003: IMEI Modification (with Luhn validation)
- FR-IMEI-004: IMEI Validation (Luhn algorithm)
- FR-IMEI-005: Backup Creation

**Supported Devices**:
| Device | Status | Method |
|--------|--------|--------|
| Huawei E3372 | Supported | AT Commands |
| Huawei E5573 | Supported | AT Commands |
| Huawei B525 | Supported | AT Commands |
| Qtech QMP-M1-N IP68 | Supported | Proprietary |

**Documents**:
- `01-requirements.md` - Business and functional requirements

---

## Notes

- **Status Inference**: Status is inferred from document headers/footers since no `_status.md` files exist.
- **Document Legend**:
  - ✓ = Document exists
  - ✗ = Document missing
- **Layer Classification**:
  - **L1 (Domain)**: Device management, hardware interaction
  - **L2 (Features)**: User-facing features, business capabilities
- **DDD vs SDD**: DDD flows focus on business requirements and stakeholder needs, while SDD flows provide technical specifications and implementation details.

## Warnings

- **No status files**: None of the 2 DDD flows have `_status.md` for tracking progress.
- **No specifications**: Neither flow has `02-specifications.md` documents.
- **No plans**: Neither flow has `03-plan.md` documents.
- **No implementation logs**: Neither flow has `04-implementation-log.md` documents.

---

*Generated automatically. Update when DDD flows are added or modified.*
