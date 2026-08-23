# Understanding: Magisk Voice Telephony Integration

## Phase: EXPLORING

## Hypothesis

The Magisk module provides system-level privileges to enable voice call recording from the phone line (radio interface) by:
1. Granting privileged permissions (CAPTURE_AUDIO_OUTPUT, MODIFY_PHONE_STATE)
2. Disabling Qualcomm audio recording restrictions via system properties
3. Installing as a system module to bypass Android security restrictions

## Sources

- `magisk/gateway/` - Magisk module root directory
- `magisk/gateway/system/etc/permissions/privapp-permissions-gateway.xml` - Privileged permissions whitelist
- `magisk/gateway/install.sh` - Module installer script
- `magisk/gateway/module.prop` - Module metadata
- `magisk/gateway/common/service.sh` - Late-start service script
- `magisk/gateway/common/post-fs-data.sh` - Post-fs-data script
- `lib/models/line_info.dart` - LineInfo.canRecordVoiceToRadio capability flag
- `lib/domain/entities/gateway_config.dart` - enableCallRecording configuration
- `flows/sdd-patch-management/02-specifications.md` - Audio API research notes
- `nmpjsip-builder/src/patch_2.9/` - PJSIP Android audio device patches

## Validated Understanding

### Magisk Module Structure

```
magisk/gateway/
├── META-INF/com/google/android/
│   ├── update-binary      # Magisk update script (v20.0+)
│   └── updater-script     # Updater script marker
├── common/
│   ├── post-fs-data.sh    # Early boot script (currently empty)
│   ├── service.sh         # Late-start service (currently empty)
│   └── system.prop        # System properties (not enabled)
├── system/
│   └── etc/permissions/
│       └── privapp-permissions-gateway.xml  # Privileged permissions
├── install.sh             # Installation script
└── module.prop            # Module metadata
```

### Privileged Permissions Granted

The Magisk module grants the following privileged permissions to `one.telefon.gateway`:

```xml
<privapp-permissions package="one.telefon.gateway">
    <permission name="android.permission.READ_LOGS"/>
    <permission name="android.permission.CAPTURE_AUDIO_OUTPUT"/>
    <permission name="android.permission.READ_PRECISE_PHONE_STATE"/>
    <permission name="android.permission.MODIFY_PHONE_STATE"/>
</privapp-permissions>
```

**Critical Permission for Voice Recording**: `CAPTURE_AUDIO_OUTPUT`
- This permission is required to capture audio from `VOICE_CALL`, `VOICE_UPLINK`, and `VOICE_DOWNLINK` sources
- Reserved for system components only (not available to third-party apps)
- Magisk module installs the app as a system app, enabling this permission

### Voice Recording Capabilities (LineInfo)

The `LineInfo` model defines three voice-related capabilities:

| Capability | Property | Description |
|------------|----------|-------------|
| Record to Radio | `canRecordVoiceToRadio` | Record voice call audio to radio interface |
| Get from Radio | `canGetVoiceFromRadio` | Receive voice audio from radio interface |
| Write to Voice Comm | `canWriteToVoiceCommunication` | Write audio to voice communication stream |

**Default Values**: All disabled (`false`) until Magisk module is installed

### Qualcomm Audio Restrictions

From research notes in `flows/sdd-patch-management/02-specifications.md`:

```properties
# Qualcomm recording restrictions (can be disabled via Magisk)
voice.record.conc.disabled=false
voice.voip.conc.disabled=false
```

**Purpose**: These properties control whether concurrent voice recording is disabled
- Setting to `false` enables concurrent recording
- Requires system-level access to modify

### PJSIP Android Audio Device Integration

From `nmpjsip-builder/src/patch_2.9/`:

**Audio Capture Sources** (require CAPTURE_AUDIO_OUTPUT):
- `VOICE_CALL` - Full call audio (both parties)
- `VOICE_UPLINK` - Local party audio only
- `VOICE_DOWNLINK` - Remote party audio only
- `VOICE_COMMUNICATION` - VoIP communication audio

**Warning from Android API**:
> "Capturing from VOICE_CALL source requires the Manifest.permission.CAPTURE_AUDIO_OUTPUT permission. This permission is reserved for use by system components and is not available to third-party applications."

### Installation Process

From `magisk/gateway/install.sh`:

```bash
on_install() {
  # Extract system files to MODPATH
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  
  # Set permissions
  set_permissions
  
  # Optional: Install CallRecorder APK (commented out)
  # unzip -oj "$ZIPFILE" 'common/CallRecorder.apk' -d $MODPATH >&2
  # pm install -r -g $MODPATH/system/priv-app/CallRecorderSKVALEXAddOn/CallRecorderAddOn.apk
}
```

**Note**: CallRecorder APK installation is currently commented out - module only grants permissions

### Module Metadata

From `magisk/gateway/module.prop`:

```
id=gateway
name=Gateway
version=1.0.0 (1.0.0)
versionCode=1
author=anton
description=Gateway App
```

### Configuration Integration

From `lib/domain/entities/gateway_config.dart`:

```dart
final bool enableCallRecording;  // Default: false
```

**Usage**: Controls whether call recording is enabled in the gateway configuration

## Children

| Child | Status |
|-------|--------|
| permissions-system | PENDING |
| audio-capture-sources | PENDING |
| qualcomm-restrictions | PENDING |
| installation-flow | PENDING |

## Flow Recommendation

**Type**: SDD (Spec-Driven Development)

**Rationale**: 
- Internal service logic (system-level integration)
- Not stakeholder-facing (end users don't interact with Magisk directly)
- Technical implementation details
- Enables voice recording capability for the gateway app

**Confidence**: high

**Flow Name**: `sdd-magisk-voice-recording`

## Bubble Up

- Magisk module grants system-level privileged permissions
- CAPTURE_AUDIO_OUTPUT enables voice call audio capture from radio
- LineInfo capabilities (canRecordVoiceToRadio) depend on Magisk installation
- Qualcomm restrictions can be disabled via system properties
- PJSIP uses Android AudioRecord API with VOICE_CALL source
- Module installs as system app via Magisk framework

---

## Phase: SPAWNING

### Identified Child Concepts

1. **permissions-system**: How privileged permissions are granted and enforced
2. **audio-capture-sources**: Different Android audio capture sources for recording
3. **qualcomm-restrictions**: Qualcomm-specific recording restrictions and workarounds
4. **installation-flow**: Magisk module installation and verification process

---

*Created by /legacy - DFS focus on Magisk voice telephony integration*
