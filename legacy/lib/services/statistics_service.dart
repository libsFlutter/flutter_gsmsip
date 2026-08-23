import 'dart:async';
import 'dart:collection';
import '../models/sms_message.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  final Map<String, int> _callCounts = HashMap();
  final Map<String, int> _smsCounts = HashMap();
  final List<Map<String, dynamic>> _callHistory = [];
  final List<Map<String, dynamic>> _smsHistory = [];

  Future<void> initialize() async {
    // Initialize statistics service
    print('Statistics service initialized');
  }

  void addCall(Map<String, dynamic> callInfo) {
    final number = callInfo['number'] as String? ?? 'Unknown';
    _callCounts[number] = (_callCounts[number] ?? 0) + 1;
    _callHistory.add(callInfo);
    
    // Keep only last 1000 calls
    if (_callHistory.length > 1000) {
      _callHistory.removeAt(0);
    }
  }

  void addSms(SmsMessage sms) {
    final number = sms.address;
    _smsCounts[number] = (_smsCounts[number] ?? 0) + 1;
    _smsHistory.add({
      'number': number,
      'message': sms.body,
      'timestamp': sms.timestamp.toIso8601String(),
      'type': sms.type.name,
    });
    
    // Keep only last 1000 SMS
    if (_smsHistory.length > 1000) {
      _smsHistory.removeAt(0);
    }
  }

  Map<String, dynamic> getSmsStatistics() {
    final totalSms = _smsHistory.length;
    final incomingSms = _smsHistory.where((sms) => sms['type'] == 'incoming').length;
    final outgoingSms = _smsHistory.where((sms) => sms['type'] == 'sent').length;
    
    return {
      'total': totalSms,
      'incoming': incomingSms,
      'outgoing': outgoingSms,
      'unique_contacts': _smsCounts.length,
    };
  }

  List<Map<String, dynamic>> getTopCalledNumbers({int limit = 10}) {
    final sortedNumbers = _callCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedNumbers.take(limit).map((entry) => {
      'number': entry.key,
      'count': entry.value,
    }).toList();
  }

  List<Map<String, dynamic>> getTopSmsContacts({int limit = 10}) {
    final sortedNumbers = _smsCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedNumbers.take(limit).map((entry) => {
      'number': entry.key,
      'count': entry.value,
    }).toList();
  }

  void dispose() {
    _callCounts.clear();
    _smsCounts.clear();
    _callHistory.clear();
    _smsHistory.clear();
  }
} 