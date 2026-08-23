# Traversal State

> Persistent recursion stack for tree traversal. AI reads this to know where it is and what to do next.

## Mode

- **BFS** (no comment): Breadth-first, analyze all domains systematically
- **DFS** (with comment): Depth-first, focus deeply on specific topic

## Source Path

[project root]

## Focus (DFS only)

magisk-voice-recording - Voice call recording from phone line via Magisk

## Existing Flows Index

| Flow Path | Type | Topics | Key Decisions |
|-----------|------|--------|---------------|
| flows/sdd-core-architecture/ | SDD | Clean Architecture, DI, error handling | get_it, ErrorHandler |
| flows/sdd-gateway-service/ | SDD | GSM↔SIP routing, orchestration | bidirectional bridge |
| flows/sdd-telephony/ | SDD | Android telephony, MethodChannel | permission_handler |
| flows/sdd-android-telecom-integration/ | SDD | InCallService, Call API | EventChannel streaming |
| flows/sdd-call-model/ | SDD | TeleCall data model | 40+ fields |
| flows/sdd-patch-management/ | SDD | PJSIP patches, audio | WebRTC AEC, Qualcomm restrictions |
| flows/sdd-magisk-voice-recording/ | SDD | Magisk, CAPTURE_AUDIO_OUTPUT, privapp permissions | systemless root, privileged permissions |
| flows/adr-001-clean-architecture/ | ADR | Architecture pattern | layers, dependencies |
| flows/adr-002-dependency-injection/ | ADR | DI framework | get_it chosen |
| flows/adr-003-state-management/ | ADR | State management | Provider chosen |
| flows/adr-004-error-handling/ | ADR | Error handling strategy | centralized ErrorHandler |
| flows/adr-005-service-orchestration/ | ADR | Service coordination | orchestration pattern |

## Current Stack

> Read top-to-bottom = root-to-current. Last item = where AI is now.

```
/ (root)                                    COMPLETED
├── magisk-voice-integration                DONE
└── apgateway-magisk-module                 EXITING
```

## Stack Operations Log

| # | Operation | Node | Phase | Result |
|---|-----------|------|-------|--------|
| 1-23 | [Previous BFS operations] | various | COMPLETED | See above |
| 24 | PUSH | magisk-voice-integration | ENTERING | DFS focus on Magisk voice recording |
| 25 | UPDATE | magisk-voice-integration | EXPLORING | Magisk module structure analyzed |
| 26 | UPDATE | magisk-voice-integration | SPAWNING | Child concepts identified |
| 27 | UPDATE | magisk-voice-integration | SYNTHESIZING | Understanding validated |
| 28 | UPDATE | magisk-voice-integration | EXITING | SDD flow created |
| 29 | POP | magisk-voice-integration | DONE | SDD: flows/sdd-magisk-voice-recording/ |
| 30 | PUSH | apgateway-magisk-module | ENTERING | Analyze third-party module |
| 31 | UPDATE | apgateway-magisk-module | EXPLORING | apgateway structure analyzed |
| 32 | UPDATE | apgateway-magisk-module | SYNTHESIZING | Comparison completed |
| 33 | UPDATE | apgateway-magisk-module | EXITING | SDD updated, gaps documented |
| 34 | POP | apgateway-magisk-module | DONE | Analysis complete |

## Current Position

- **Node**: / (root)
- **Phase**: COMPLETED (DFS focus complete)
- **Depth**: 0
- **Path**: /

## Pending Children

> Children identified but not yet explored (LIFO - last added explored first)

```
[none - DFS focus complete]
```

## Visited Nodes

> Completed nodes with their summaries

| Node Path | Summary | Flow Created |
|-----------|---------|--------------|
| core-architecture | Clean Architecture, get_it DI, ErrorHandler | SDD: flows/sdd-core-architecture/ |
| gateway-service | Gateway orchestration, bidirectional routing | SDD: flows/sdd-gateway-service/ |
| telephony-integration | Android telephony via MethodChannel | - |
| sip-protocol | SIP VoIP call handling | - |
| smpp-protocol | SMS/SMPP messaging | - |
| ui-theming | Theme management (Light/Dark/System) | - |
| logging-monitoring | Connection monitoring, latency tracking | - |
| testing-strategy | Unit/widget/integration test coverage | - |
| **magisk-voice-integration** | **Magisk module, CAPTURE_AUDIO_OUTPUT, privapp permissions, Qualcomm restrictions** | **SDD: flows/sdd-magisk-voice-recording/** |
| **apgateway-magisk-module** | **Third-party module analysis: enhanced system.prop, 11 permissions, APK sync service** | **SDD updated, gaps documented** |

## DFS Focus Summary: Magisk Voice Recording

**Objective**: Document Magisk module for voice call recording from phone line

**Sources Analyzed**:
- `magisk/gateway/` - Our Magisk module structure
- `magisk/gateway/system/etc/permissions/privapp-permissions-gateway.xml` - Privileged permissions
- `lib/models/line_info.dart` - LineInfo.canRecordVoiceToRadio capability
- `lib/domain/entities/gateway_config.dart` - enableCallRecording config
- `nmpjsip-builder/src/patch_2.9/` - PJSIP Android audio device (VOICE_CALL source)
- `flows/sdd-patch-management/02-specifications.md` - Qualcomm restrictions research

**Key Findings**:
1. Magisk grants CAPTURE_AUDIO_OUTPUT permission (required for VOICE_CALL audio capture)
2. Privapp permissions whitelist enables system-level access for gateway app
3. LineInfo exposes voice recording capabilities (canRecordVoiceToRadio, etc.)
4. Qualcomm restrictions can be disabled via system properties
5. PJSIP uses Android AudioRecord API with VOICE_CALL source

**Flow Created**: `flows/sdd-magisk-voice-recording/`
- 01-requirements.md: Functional/non-functional requirements
- 02-specifications.md: Architecture, components, testing specs
- _status.md: DRAFT status, progress tracking

## DFS Focus Summary: apgateway Third-Party Module Analysis

**Objective**: Analyze third-party developer's Magisk module implementation for voice line integration

**Sources Analyzed**:
- `3rdparty/apgateway/` - Third-party Magisk module (callagent)
- `3rdparty/apgateway/module.prop` - Module metadata
- `3rdparty/apgateway/install.sh` - Enhanced installer with APK fallback
- `3rdparty/apgateway/system.prop` - Qualcomm audio restrictions (7 properties)
- `3rdparty/apgateway/service.sh` - APK synchronization service
- `3rdparty/apgateway/post-fs-data.sh` - Mount guarantee
- `3rdparty/apgateway/system/etc/permissions/privapp-permissions-gateway.xml` - 11 permissions
- `3rdparty/apgateway/META-INF/com/google/android/update-binary` - Standard Magisk install_module

**Key Findings**:
1. **system.prop ENABLED** - Disables 7 Qualcomm audio restrictions (including Fluence)
2. **11 Privileged Permissions** - Full telephony/telecom integration (we have only 4)
3. **APK Sync Service** - Automatically syncs app updates to priv-app overlay
4. **Mount Guarantee** - post-fs-data.sh removes skip_mount
5. **Enhanced Installer** - APK fallback copying, user guidance
6. **Standard update-binary** - Uses Magisk install_module function

**Comparison Result**: apgateway module is MORE COMPLETE than our implementation

**Critical Gaps in Our Module**:
1. system.prop DISABLED (PROPFILE=false) - Cannot disable Qualcomm restrictions
2. Only 4 permissions vs 11 - Limited telephony/telecom capabilities
3. No service.sh - No APK sync or permission logging
4. No post-fs-data.sh - May fail if skip_mount exists
5. Basic install.sh - No fallback logic

**Actions Taken**:
1. ✅ Updated `flows/sdd-magisk-voice-recording/02-specifications.md` with Legacy Additions
2. ✅ Created `flows/legacy/apgateway-analysis.md` with gaps and recommendations
3. ✅ Created `flows/legacy/understanding/apgateway-magisk-module/_node.md`

**Recommendations for apgateway Developer**:
- ✅ No critical changes needed - module is production-ready
- ℹ️ Optional: Add more inline documentation
- ℹ️ Optional: Use semantic versioning in module.prop
- ℹ️ Optional: Consider lowering Magisk requirement to v20.0+

**What We're Adopting from apgateway**:
- ✅ Enhanced system.prop configuration (7 properties)
- ✅ Extended privileged permissions (11 total)
- ✅ service.sh for APK synchronization
- ✅ post-fs-data.sh for mount guarantee
- ✅ Enhanced install.sh with fallback logic

## Next Action

```
DFS traversal complete. Magisk voice recording integration documented.

Options:
1. Review and approve sdd-magisk-voice-recording flow
2. Continue DFS on other topics (specify with: /legacy path "topic")
3. Resume BFS traversal for remaining domains
4. Create ADR for Magisk integration decision
```

---

## Phase Definitions

### ENTERING
- Just arrived at this node
- Create _node.md file
- Read relevant source files
- Form initial hypothesis

### EXPLORING
- Deep analysis of this node's scope
- Validate/refine hypothesis
- Identify what belongs here vs. children

### SPAWNING
- Identify child concepts that need deeper exploration
- Add children to Pending stack
- Children are LOGICAL concepts, not filesystem paths

### SYNTHESIZING
- All children completed (or no children)
- Combine insights from children
- Update this node's _node.md with full understanding

### EXITING
- Pop from stack
- Bubble up summary to parent
- Mark as visited

---

## Resume Protocol

When `/legacy` starts:
1. Read _traverse.md
2. Find current position (top of stack)
3. Check phase
4. Continue from that phase

If interrupted mid-phase:
- Re-enter same phase (idempotent operations)

---

*Updated by /legacy recursive traversal*
