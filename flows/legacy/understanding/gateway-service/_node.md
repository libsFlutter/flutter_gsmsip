# Understanding: Gateway Service

## Phase: EXITING

## Validated Understanding

**GatewayService** is the central orchestrator that coordinates bidirectional routing between GSM and SIP/SMPP networks.

### Core Responsibilities:

1. **Service Orchestration**
   - Initializes and manages SipService, SmsService, TelephonyService
   - Coordinates service lifecycle (initialize/start/stop/dispose)
   - Event listener setup for all sub-services

2. **Call Routing (Bidirectional)**
   - **SIP→GSM**: SIP call triggers GSM call creation
   - **GSM→SIP**: Incoming GSM call triggers SIP call creation
   - Auto-answer support for GSM calls
   - Call state synchronization between protocols

3. **SMS Routing**
   - Local SMS sending via telephony
   - SMPP SMS sending (when configured)
   - Message handling and counting

4. **State Management**
   - GatewayStatus tracking (running state, connection states, statistics)
   - CallRouting tracking (active routings with state machine)
   - Stream-based state updates (statusStream, routingStream, logStream)

5. **Configuration Persistence**
   - GatewayConfig save/load via SharedPreferences
   - JSON serialization support

### Key Classes:

```dart
GatewayConfig          // Configuration (SIP account, SMPP config, routing flags)
GatewayStatus          // Status snapshot (connections, statistics, uptime)
CallRouting            // Active call routing (IDs, direction, state, timing)
CallRoutingDirection   // sipToGsm | gsmToSip
CallRoutingState       // connecting | active | ended | failed
```

### Configuration Options:

| Option | Default | Purpose |
|--------|---------|---------|
| sipAccount | required | SIP credentials |
| smppConfig | null | SMPP configuration (optional) |
| autoAnswer | false | Auto-answer incoming GSM calls |
| enableLogging | true | Enable log streaming |
| routeSipToGsm | true | Enable SIP→GSM routing |
| routeGsmToSip | true | Enable GSM→SIP routing |
| routeSmsToSmpp | false | Enable SMS→SMPP routing |
| routeSmppToSms | false | Enable SMPP→SMS routing |
| maxConcurrentCalls | 5 | Maximum concurrent calls |

### State Machine:

```
CallRoutingState:
  connecting ──► active ──► ended
                      │
                      └──► failed
```

### Flow Diagram:

```
GatewayService.initialize(config)
       │
       ├─► TelephonyService.initialize()
       ├─► SipService.initialize(sipAccount)
       ├─► SmsService.initializeSmpp(smppConfig) [optional]
       └─► _setupEventListeners()
            │
            ├─► _sipService.callStateStream → _handleSipCallStateChange
            ├─► _smsService.messageStream → _handleSmsMessage
            └─► _telephonyService.callStateStream → _handleTelephonyCallStateChange

GatewayService.start()
       │
       ├─► _sipService.register()
       ├─► _smsService.connectSmpp() [if configured]
       └─► _isRunning = true

SIP→GSM Call Flow:
  makeCallViaSip(number)
       │
       ├─► _sipService.makeCall(number) → sipCallId
       ├─► Create CallRouting (direction: sipToGsm, state: connecting)
       ├─► Listen for SIP call state = active
       └─► _makeGsmCallForRouting(routingId, number)
            │
            ├─► _telephonyService.makeCall(number) → telephonyCallId
            └─► Update CallRouting (state: active)

GSM→SIP Call Flow:
  _handleIncomingGsmCall(gsmCall)
       │
       ├─► _sipService.makeCall(gsmCall.number) → sipCallId
       ├─► Create CallRouting (direction: gsmToSip, state: connecting)
       ├─► _telephonyService.answerCall() [if autoAnswer]
       └─► Update statistics
```

### Statistics Tracking:

- `activeCalls` - Current active routings count
- `totalCallsHandled` - Lifetime call count
- `totalMessagesHandled` - Lifetime SMS count
- `startTime` - Gateway start timestamp
- `uptime` - Calculated from startTime

## Sources

- `lib/services/gateway_service.dart` - Main gateway orchestration (450+ lines)
- `lib/data/repositories/gateway_repository.dart` - Repository interface
- `lib/data/repositories/gateway_repository_impl.dart` - Repository implementation

## Flow Created

**SDD**: `flows/sdd-gateway-service/`
- 01-requirements.md - Functional and non-functional requirements
- 02-specifications.md - Component specs, API specs, data flows
- _status.md - DRAFT status

## Bubble Up

- Central orchestrator for GSM↔SIP/SMPP bridge
- Bidirectional call routing with state machine
- Service lifecycle management
- Stream-based state updates
- Persistent configuration
- SDD flow created (DRAFT)
