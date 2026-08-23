# Understanding: Telephony Integration

## Phase: EXITING

## Validated Understanding

**TelephonyService** provides Android GSM telephony integration via platform channels.

### Core Capabilities:

1. **Call Management**
   - Make outgoing calls via Android telephony
   - Answer incoming calls
   - End active calls
   - Track call state changes (idle, ringing, offhook, active, hold, ended)

2. **Permission Handling**
   - Request: phone, sms, microphone, manageExternalStorage
   - Check permission status (granted, denied, permanentlyDenied, restricted)
   - Permission-based feature availability

3. **Device Information**
   - Get phone number
   - Get network operator name
   - Get SIM serial number
   - Get signal strength

4. **USSD Support**
   - Send USSD codes
   - Receive USSD responses

5. **Event Streaming**
   - callStateStream - Real-time call state updates
   - logStream - Service logging
   - phoneStateStream - Phone state changes

### Platform Channel Integration:

```dart
static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/telephony');

// Native methods:
- initialize()
- makeCall({number})
- answerCall()
- endCall()
- getPhoneNumber()
- getNetworkOperatorName()
- getSimSerialNumber()
- getSignalStrength()
- sendUssd({ussdCode})

// Native callbacks:
- onCallStateChanged
- onPhoneStateChanged
- onIncomingCall
```

### Call State Machine:

```
idle ──► ringing ──► offhook ──► active ──► hold ──► ended
                    │                              │
                    └──────────────────────────────┘
```

## Sources

- `lib/services/telephony_service.dart` - Main telephony service (350+ lines)

## Flow Recommendation

**Type**: SDD
**Confidence**: high
**Rationale**: Platform-specific integration service

## Bubble Up

- Android telephony via MethodChannel
- Permission-based access control
- Real-time call state streaming
- USSD code support
