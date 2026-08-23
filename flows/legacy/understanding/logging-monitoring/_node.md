# Understanding: Logging & Monitoring

## Phase: EXITING

## Validated Understanding

**ConnectionMonitorService** provides real-time monitoring of SIP/SMPP connections.

### Core Capabilities:

1. **Connection Monitoring**
   - Periodic TCP connection checks (5-second intervals)
   - SIP server connectivity monitoring
   - SMPP server connectivity monitoring
   - Latency measurement (stopwatch timing)

2. **Network Status Tracking**
   - Connectivity type detection (WiFi, mobile, none)
   - Network quality calculation (Excellent, Good, Fair, Poor)
   - Signal strength monitoring
   - Network change event handling

3. **Statistics Collection**:

```dart
class ConnectionStats {
  final String protocol;           // "SIP" or "SMPP"
  final bool isConnected;
  final double latency;            // milliseconds
  final DateTime lastUpdate;
  final String? errorMessage;
  final int reconnectAttempts;
}
```

4. **Event Streaming**
   - sipStatsStream - SIP connection statistics
   - smppStatsStream - SMPP connection statistics
   - networkStatusStream - Network status updates

5. **Speed Test**
   - Download speed measurement via httpbin.org
   - Results in bps and kbps
   - Latency measurement

### Monitoring Cycle:

```
startMonitoring()
       │
       ├─► Subscribe to connectivity changes
       ├─► Start periodic timer (5 seconds)
       └─► _performMonitoringCycle()
            │
            ├─► _updateNetworkStatus()
            ├─► _checkSipConnection(server, port)
            │    └─► Socket.connect() with 5s timeout
            │    └─► Measure latency with Stopwatch
            └─► _checkSmppConnection(server, port)
                 └─► Socket.connect() with 5s timeout
```

### Network Quality Calculation:

| Average Latency | Quality |
|-----------------|---------|
| < 50ms | Excellent |
| 50-100ms | Good |
| 100-200ms | Fair |
| > 200ms | Poor |

### Detailed Statistics:

```dart
getDetailedStats(period: Duration) → {
  'period_start': ISO8601,
  'period_end': ISO8601,
  'sip_stats': {
    'average_latency': double,
    'connection_uptime': percentage,
    'reconnect_attempts': int,
    'last_error': String,
  },
  'smpp_stats': {...},
  'network_quality': String,
  'monitoring_active': bool,
}
```

## Sources

- `lib/services/connection_monitor_service.dart` - Monitoring service
- `lib/models/connection_stats.dart` - Statistics model

## Flow Recommendation

**Type**: SDD
**Confidence**: high
**Rationale**: Internal monitoring service

## Bubble Up

- Real-time connection monitoring
- Latency measurement
- Network quality assessment
- Speed test capability
