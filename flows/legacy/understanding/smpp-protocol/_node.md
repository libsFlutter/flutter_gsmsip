# Understanding: SMPP Protocol

## Phase: EXITING

## Validated Understanding

**SmsService** handles SMS messaging via SMPP protocol and local Android SMS.

### Core Capabilities:

1. **SMPP Connection Management**
   - Configure SMPP connection (host, port, systemId, password, systemType)
   - Connect to SMPP server
   - Disconnect from SMPP server
   - Connection state tracking (disconnected, connecting, bound, error)

2. **SMS Operations**
   - Send SMS via SMPP (`sendSmsViaSmpp`)
   - Send SMS via local Android (`sendSmsLocal`)
   - Message history with filtering
   - Message statistics

3. **Message Model**:

```dart
class SmsMessage {
  final String id;
  final String sender;
  final String recipient;
  final String content;
  final DateTime timestamp;
  final SmsMessageType type;   // incoming | outgoing
  final SmsMessageStatus status; // pending, sent, delivered, failed, received
}
```

4. **Message State Machine**:

```
Outgoing: pending ──► sent ──► delivered
                     │
                     └──► failed

Incoming: received
```

5. **Event Streaming**
   - connectionStateStream - SMPP connection state
   - messageStream - Message updates
   - logStream - Service logging

### SMPP Configuration:

```dart
class SmppConfig {
  final String host;
  final int port;
  final String systemId;
  final String password;
  final String systemType;
  final String sourceAddrTon;
  final String sourceAddrNpi;
  final String addressRange;
}
```

### Message Statistics:

- Total messages count
- Incoming/outgoing breakdown
- Status breakdown (sent, delivered, failed)
- Message history filtering (sender, recipient, type, date range)

### Testing Support:

- `simulateIncomingSms(sender, content)` - Simulate incoming SMS
- `_simulateMessageDelivery()` - Automatic delivery simulation (95% success rate)

## Sources

- `lib/services/sms_service.dart` - SMS/SMPP service implementation (350+ lines)

## Flow Recommendation

**Type**: SDD
**Confidence**: high
**Rationale**: Protocol implementation service

## Bubble Up

- SMPP connection/binding
- Dual SMS sending (SMPP or local)
- Message lifecycle tracking
- Statistics and filtering
