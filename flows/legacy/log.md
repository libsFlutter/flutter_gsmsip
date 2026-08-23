# Legacy Analysis Log

## Session History

### 2026-03-06 - DFS #2: apgateway Third-Party Module Analysis

**Mode**: DFS (Depth-First Search) - Comparative Analysis
**Target**: 3rdparty/apgateway - Third-party Magisk module for voice line integration
**Command**: `/legacy проанализируй папку стороннего разработчика /3rdparty/apgateway на работу с линией через Magisk`

**Analyzed**:
- `3rdparty/apgateway/` - Third-party Magisk module by callagent
- `3rdparty/apgateway/module.prop` - Module metadata (sip-gsm-gateway)
- `3rdparty/apgateway/install.sh` - Enhanced installer with APK fallback
- `3rdparty/apgateway/system.prop` - 7 Qualcomm audio restrictions properties
- `3rdparty/apgateway/service.sh` - APK synchronization service
- `3rdparty/apgateway/post-fs-data.sh` - Mount guarantee
- `3rdparty/apgateway/system/etc/permissions/privapp-permissions-gateway.xml` - 11 privileged permissions
- `3rdparty/apgateway/META-INF/com/google/android/update-binary` - Standard install_module
- Compared with our `magisk/gateway/` module

**Key Findings**:
1. **apgateway is MORE COMPLETE** than our implementation
2. **system.prop ENABLED** - 7 Qualcomm properties (voice.record.conc.disabled, Fluence disable, etc.)
3. **11 Privileged Permissions** - Full telephony/telecom (we have only 4)
4. **APK Sync Service** - Automatically syncs updates from /data/app to priv-app
5. **Mount Guarantee** - post-fs-data.sh removes skip_mount
6. **Enhanced Installer** - APK fallback, user guidance, SKIPUNZIP=1
7. **Standard update-binary** - Uses Magisk install_module function (requires v20.4+)

**Comparison Table**:

| Feature | apgateway | Our Module | Gap |
|---------|-----------|------------|-----|
| system.prop | ✅ ENABLED (7 properties) | ❌ DISABLED | ⚠️ Critical |
| Permissions | 11 | 4 | ⚠️ Missing 7 |
| service.sh | ✅ APK sync + logging | ❌ None | ⚠️ Missing |
| post-fs-data.sh | ✅ Mount guarantee | ❌ Empty | ⚠️ Missing |
| install.sh | ✅ Enhanced with fallback | ❌ Basic | ⚠️ Missing features |
| update-binary | ✅ Standard install_module | ❌ Manual | ⚠️ Less robust |
| APK Bundling | ✅ Bundled | ❌ Not bundled | ℹ️ Design choice |

**Updated**:
- `flows/sdd-magisk-voice-recording/02-specifications.md` - Added "Legacy Additions" section with:
  - Enhanced system.prop configuration (7 properties)
  - Extended privileged permissions (11 total)
  - service.sh implementation example
  - post-fs-data.sh implementation example
  - Enhanced install.sh recommendations
  - update-binary standardization recommendations

**Created**:
- `flows/legacy/understanding/apgateway-magisk-module/_node.md` - Understanding tree node
- `flows/legacy/apgateway-analysis.md` - Gaps and recommendations document

**Recommendations for apgateway Developer (callagent)**:
- ✅ **No critical changes needed** - Module is production-ready
- ℹ️ Optional: Add more inline documentation
- ℹ️ Optional: Use semantic versioning in module.prop
- ℹ️ Optional: Consider lowering Magisk requirement to v20.0+

**What We're Adopting from apgateway**:
- ✅ Enhanced system.prop configuration (7 properties for Qualcomm)
- ✅ Extended privileged permissions (11 total)
- ✅ service.sh for APK synchronization
- ✅ post-fs-data.sh for mount guarantee
- ✅ Enhanced install.sh with fallback logic

---

### 2026-03-06 - DFS #1: Magisk Voice Recording Integration

**Mode**: DFS (Depth-First Search)
**Target**: magisk-voice-recording - Voice call recording from phone line via Magisk
**Command**: `/legacy /magisk составь sdd-magisk по включению работы голосом с телефонной линией`

**Analyzed**:
- `magisk/gateway/`: Magisk module structure (META-INF, common, system, install.sh, module.prop)
- `magisk/gateway/system/etc/permissions/privapp-permissions-gateway.xml`: Privileged permissions whitelist
- `lib/models/line_info.dart`: LineInfo model with voice capabilities (canRecordVoiceToRadio, etc.)
- `lib/domain/entities/gateway_config.dart`: enableCallRecording configuration flag
- `nmpjsip-builder/src/patch_2.9/`: PJSIP Android audio device (VOICE_CALL, VOICE_UPLINK, VOICE_DOWNLINK sources)
- `flows/sdd-patch-management/02-specifications.md`: Qualcomm audio restrictions research
- `flows/sdd-android-telecom-integration/`: Existing telecom integration documentation
- `flows/sdd-telephony/`: Existing telephony service documentation

**Key Findings**:
1. **Magisk Module**: Grants system-level privileged permissions via privapp-permissions-gateway.xml
2. **CAPTURE_AUDIO_OUTPUT**: Required permission for VOICE_CALL audio capture (reserved for system apps)
3. **LineInfo Capabilities**: canRecordVoiceToRadio, canGetVoiceFromRadio, canWriteToVoiceCommunication (all false by default)
4. **Qualcomm Restrictions**: voice.record.conc.disabled=false, voice.voip.conc.disabled=false (can be disabled via system.prop)
5. **PJSIP Integration**: Uses Android AudioRecord API with VOICE_CALL source for bidirectional call recording
6. **Gateway Config**: enableCallRecording flag controls recording feature (default: false)

**Created**:
- `flows/sdd-magisk-voice-recording/01-requirements.md`: Functional/non-functional requirements
- `flows/sdd-magisk-voice-recording/02-specifications.md`: Architecture, components, testing specifications
- `flows/sdd-magisk-voice-recording/_status.md`: DRAFT status, progress tracking
- `flows/legacy/understanding/magisk-voice-integration/_node.md`: Understanding tree node

**Flow Matching**:
- No existing flow matched (score < 2)
- Created new SDD flow: `sdd-magisk-voice-recording`
- Reason: Magisk system integration is distinct from existing telephony/SIP flows

**Next Actions**:
1. Review and approve sdd-magisk-voice-recording flow
2. Consider creating ADR for Magisk integration architectural decision
3. Implement Magisk module enhancements (system.prop for Qualcomm, boot scripts)
4. Test on target devices (Qualcomm chipsets)

---

*Append new entries at the top.*
