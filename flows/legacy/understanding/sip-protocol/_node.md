# Understanding: SIP Protocol

## Phase: EXITING

## Validated Understanding

**SipService** handles VoIP calls via SIP protocol (simulated implementation).

### Core Capabilities:

1. **SIP Account Management**
   - Configure SIP account (username, password, domain, proxy, port)
   - Secure SIP support (useSecure flag)
   - Account serialization (JSON)

2. **Connection Management**
   - Initialize with SIP account
   - Register with SIP server
   - Unregister from SIP server
   - Connection state tracking (disconnected, connecting, connected, error)

3. **Call Operations**
   - Make outgoing calls
   - Answer incoming calls
   - End calls
   - Hold/resume calls
   - Call state tracking

4. **Call State Machine**:

```
Outgoing: connecting ──► ringing ──► active ──► hold ──► active ──► ended
                                                        │
Incoming: ringing ──► active ──────────────────────────┘
```

5. **Event Streaming**
   - connectionStateStream - SIP connection state
   - callStateStream - Individual call states
   - logStream - Service logging

### SipCall Entity:

```dart
class SipCall {
  final String id;
  final String remoteNumber;
  final SipCallDirection direction;  // incoming | outgoing
  final SipCallState state;          // connecting, ringing, active, hold, ended, failed
  final DateTime startTime;
  final Duration? duration;
}
```

### Testing Support:

- `simulateIncomingCall(fromNumber)` - Simulate incoming calls
- `_simulateCallProgression()` - Automatic call state progression for testing

## Sources

- `lib/services/sip_service.dart` - SIP service implementation (300+ lines)

## Flow Recommendation

**Type**: SDD
**Confidence**: high
**Rationale**: Protocol implementation service

## Bubble Up

- SIP account configuration
- Registration/connection management
- Full call lifecycle (make, answer, hold, end)
- Simulated implementation (ready for native integration)
