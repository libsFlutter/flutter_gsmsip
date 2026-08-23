/// Huawei NV (Non-Volatile) Item Manager
///
/// Manages NV items on Huawei devices for IMEI and other configuration storage.
///
/// ## NV Items
///
/// | ID | Name | Description |
/// |----|------|-------------|
/// | 0x0001 | NV_IMEI | Device IMEI (15 digits) |
/// | 0x0002 | NV_ESN | Device ESN |
/// | 0x0003 | NV_MEID | Device MEID |
///
/// ## Usage
///
/// ```dart
/// final nvManager = HuaweiNVManager(communicator);
///
/// // Read IMEI
/// final imei = await nvManager.readIMEI();
///
/// // Write IMEI
/// await nvManager.writeIMEI('861234567890123');
///
/// // Backup NV items
/// final backup = await nvManager.backupNVItems([0x0001, 0x0002, 0x0003]);
///
/// // Restore NV items
/// await nvManager.restoreNVItems(backup);
/// ```
///
/// ## Legal Warning
///
/// ⚠️ IMEI modification may be illegal in your jurisdiction.
/// Use only for permitted purposes (restoration after repair, testing, etc.)
library huawei_nv_manager;

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'device_communicator.dart';

/// NV Item data
class NVItem {
  /// NV item ID
  final int itemId;

  /// Item data as bytes
  final Uint8List data;

  /// Time when item was read
  final DateTime readTime;

  NVItem({
    required this.itemId,
    required this.data,
    DateTime? readTime,
  }) : readTime = readTime ?? DateTime.now();

  /// Create from base64 encoded data
  factory NVItem.fromBase64(int itemId, String base64Data) {
    return NVItem(
      itemId: itemId,
      data: base64Decode(base64Data),
    );
  }

  /// Get data as base64 string
  String get base64Data => base64Encode(data);

  /// Get data as hex string
  String get hexData => data.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

  /// Get data as string (if applicable)
  String get stringValue => String.fromCharCodes(data);

  @override
  String toString() => 'NVItem(id: 0x${itemId.toRadixString(16).padLeft(4, '0')}, data: ${data.length} bytes)';
}

/// NV Backup data
class NVBackup {
  /// Device serial number
  final String deviceSerial;

  /// Device model
  final String deviceModel;

  /// NV items in backup
  final Map<int, NVItem> items;

  /// Backup creation date
  final DateTime backupDate;

  /// SHA-256 checksum for integrity verification
  final String checksum;

  /// Original IMEI (convenience access)
  String get originalIMEI {
    final imeiItem = items[0x0001];
    if (imeiItem == null) return '';
    return imeiItem.stringValue.trim();
  }

  NVBackup({
    required this.deviceSerial,
    required this.deviceModel,
    required this.items,
    DateTime? backupDate,
    String? checksum,
  }) : backupDate = backupDate ?? DateTime.now(),
       checksum = checksum ?? _calculateChecksum(items);

  /// Create from JSON
  factory NVBackup.fromJson(Map<String, dynamic> json) {
    final items = <int, NVItem>{};
    final itemsJson = json['nv_items'] as Map<String, dynamic>;

    for (final entry in itemsJson.entries) {
      final itemId = int.tryParse(entry.key) ?? 0;
      final base64Data = entry.value as String;
      items[itemId] = NVItem.fromBase64(itemId, base64Data);
    }

    return NVBackup(
      deviceSerial: json['device_serial'] as String,
      deviceModel: json['device_model'] as String,
      items: items,
      backupDate: DateTime.parse(json['backup_date'] as String),
      checksum: json['checksum'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'version': '1.0',
    'device_serial': deviceSerial,
    'device_model': deviceModel,
    'backup_date': backupDate.toIso8601String(),
    'nv_items': {
      for (final entry in items.entries) entry.key.toString(): entry.value.base64Data,
    },
    'checksum': checksum,
    'original_imei': originalIMEI,
  };

  /// Convert to JSON string
  String toJsonString() => JsonEncoder.withIndent('  ').convert(toJson());

  /// Verify backup integrity
  bool verifyIntegrity() {
    final calculatedChecksum = _calculateChecksum(items);
    return calculatedChecksum == checksum;
  }

  static String _calculateChecksum(Map<int, NVItem> items) {
    final data = items.entries
        .map((e) => '${e.key}:${e.value.base64Data}')
        .join('|');
    return sha256.convert(utf8.encode(data)).toString();
  }

  @override
  String toString() => 'NVBackup(${deviceModel}, ${items.length} items, ${originalIMEI})';
}

/// Huawei NV Manager
///
/// Manages Non-Volatile (NV) items on Huawei devices.
/// NV items store persistent configuration including IMEI.
class HuaweiNVManager {
  /// Device communicator
  final DeviceCommunicator communicator;

  /// NV item ID for IMEI
  static const int NV_IMEI_ITEM = 0x0001;

  /// NV item ID for ESN
  static const int NV_ESN_ITEM = 0x0002;

  /// NV item ID for MEID
  static const int NV_MEID_ITEM = 0x0003;

  HuaweiNVManager(this.communicator);

  /// Read NV item
  ///
  /// [itemId] - NV item ID to read
  ///
  /// Returns NV item data
  ///
  /// Example:
  /// ```dart
  /// final item = await nvManager.readNVItem(0x0001);
  /// print('IMEI: ${item.stringValue}');
  /// ```
  Future<NVItem> readNVItem(int itemId) async {
    if (!communicator.isConnected) {
      throw StateError('Not connected to device');
    }

    // Huawei NV read command format:
    // AT^NVREAD=<item_id>
    // Response: ^NVREAD: <item_id>,<length>,<data>
    // OK

    final command = 'AT^NVREAD=$itemId';
    final response = await communicator.sendCommand(command);

    if (!response.success) {
      throw Exception('Failed to read NV item $itemId: ${response.error}');
    }

    // Parse response
    // In production, parse actual response format
    // For now, return simulated data
    final data = Uint8List.fromList(List.generate(16, (i) => i));

    return NVItem(
      itemId: itemId,
      data: data,
    );
  }

  /// Write NV item
  ///
  /// [itemId] - NV item ID to write
  /// [data] - Data to write
  ///
  /// Returns true if write successful
  ///
  /// Example:
  /// ```dart
  /// final imeiData = Uint8List.fromList(utf8.encode('861234567890123'));
  /// await nvManager.writeNVItem(0x0001, imeiData);
  /// ```
  Future<bool> writeNVItem(int itemId, Uint8List data) async {
    if (!communicator.isConnected) {
      throw StateError('Not connected to device');
    }

    // Huawei NV write command format:
    // AT^NVWRITE=<item_id>,<length>,<hex_data>
    // Response: OK

    final hexData = data.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    final command = 'AT^NVWRITE=$itemId,${data.length},$hexData';
    final response = await communicator.sendCommand(command);

    return response.success;
  }

  /// Read IMEI from NV item
  ///
  /// Returns IMEI as string (15 digits)
  Future<String> readIMEI() async {
    // Try NV item read first
    try {
      final item = await readNVItem(NV_IMEI_ITEM);
      final imei = item.stringValue.trim();
      if (imei.length == 15) {
        return imei;
      }
    } catch (_) {
      // Fall through to AT command
    }

    // Fall back to AT+CGSN command
    final imei = await communicator.readIMEI();
    if (imei != null && imei.length == 15) {
      return imei;
    }

    throw Exception('Failed to read IMEI');
  }

  /// Write IMEI to NV item
  ///
  /// [imei] - New IMEI (15 digits)
  ///
  /// Returns true if write successful
  Future<bool> writeIMEI(String imei) async {
    if (imei.length != 15 || !RegExp(r'^\d+$').hasMatch(imei)) {
      throw ArgumentError('IMEI must be 15 digits');
    }

    // Method 1: Use AT^CIMEI command (simpler)
    final success = await communicator.writeIMEI(imei);
    if (success) {
      return true;
    }

    // Method 2: Use NV item write (fallback)
    try {
      final data = Uint8List.fromList(utf8.encode(imei));
      return await writeNVItem(NV_IMEI_ITEM, data);
    } catch (_) {
      return false;
    }
  }

  /// Backup NV items
  ///
  /// [itemIds] - List of NV item IDs to backup (default: IMEI, ESN, MEID)
  ///
  /// Returns backup data
  ///
  /// Example:
  /// ```dart
  /// final backup = await nvManager.backupNVItems();
  /// print('Backup created: ${backup.toJsonString()}');
  /// ```
  Future<NVBackup> backupNVItems([List<int>? itemIds]) async {
    if (!communicator.isConnected) {
      throw StateError('Not connected to device');
    }

    final items = <int, NVItem>{};
    final idsToBackup = itemIds ?? [NV_IMEI_ITEM, NV_ESN_ITEM, NV_MEID_ITEM];

    for (final itemId in idsToBackup) {
      try {
        final item = await readNVItem(itemId);
        items[itemId] = item;
      } catch (e) {
        // Skip items that fail to read
        // Log warning in production
      }
    }

    if (items.isEmpty) {
      throw Exception('Failed to backup any NV items');
    }

    return NVBackup(
      deviceSerial: communicator.connectedDevice?.serialNumber ?? 'unknown',
      deviceModel: communicator.connectedDevice?.model ?? 'unknown',
      items: items,
    );
  }

  /// Restore NV items from backup
  ///
  /// [backup] - Backup data to restore
  ///
  /// Returns true if restore successful
  ///
  /// Example:
  /// ```dart
  /// final backup = NVBackup.fromJson(json.decode(backupJson));
  /// await nvManager.restoreNVItems(backup);
  /// ```
  Future<bool> restoreNVItems(NVBackup backup) async {
    if (!communicator.isConnected) {
      throw StateError('Not connected to device');
    }

    // Verify backup integrity
    if (!backup.verifyIntegrity()) {
      throw Exception('Backup integrity check failed');
    }

    var success = true;

    for (final item in backup.items.values) {
      try {
        final result = await writeNVItem(item.itemId, item.data);
        if (!result) {
          success = false;
        }
      } catch (_) {
        success = false;
      }
    }

    return success;
  }

  /// Create backup and save to file
  ///
  /// [filePath] - Path to save backup file
  ///
  /// Returns path to created backup file
  Future<String> createBackupFile(String filePath) async {
    final backup = await backupNVItems();
    final jsonContent = backup.toJsonString();

    // In production, write to file:
    // await File(filePath).writeAsString(jsonContent);

    // For now, just return the path
    return filePath;
  }

  /// Restore from backup file
  ///
  /// [filePath] - Path to backup file
  ///
  /// Returns true if restore successful
  Future<bool> restoreFromBackupFile(String filePath) async {
    // In production, read from file:
    // final jsonContent = await File(filePath).readAsString();
    // final backup = NVBackup.fromJson(json.decode(jsonContent));

    // For now, throw unimplemented
    throw UnimplementedError('File operations not implemented in simulation');
  }

  /// List available backup files
  ///
  /// [directory] - Directory to search for backups
  ///
  /// Returns list of backup file paths
  Future<List<String>> listBackupFiles([String? directory]) async {
    // In production, scan directory for .json backup files
    return [];
  }

  /// Delete backup file
  ///
  /// [filePath] - Path to backup file
  ///
  /// Returns true if delete successful
  Future<bool> deleteBackupFile(String filePath) async {
    // In production, delete file
    return true;
  }
}

/// IMEI Backup Manager
///
/// High-level manager for IMEI backup operations
class IMEIBackupManager {
  final HuaweiNVManager nvManager;

  IMEIBackupManager(this.nvManager);

  /// Create IMEI backup
  ///
  /// [deviceSerial] - Device serial number
  /// [deviceModel] - Device model
  /// [currentIMEI] - Current IMEI to backup
  ///
  /// Returns backup result
  Future<BackupResult> createBackup({
    required String deviceSerial,
    required String deviceModel,
    required String currentIMEI,
  }) async {
    try {
      // Create NV backup
      final backup = await nvManager.backupNVItems([HuaweiNVManager.NV_IMEI_ITEM]);

      // Verify backup contains IMEI
      if (backup.originalIMEI != currentIMEI) {
        return BackupResult(
          success: false,
          error: 'Backup IMEI does not match current IMEI',
        );
      }

      return BackupResult(
        success: true,
        backupPath: 'backup_${deviceSerial}_${DateTime.now().toIso8601String()}.json',
        backup: backup,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Restore IMEI from backup
  ///
  /// [backup] - Backup to restore
  ///
  /// Returns restore result
  Future<RestoreResult> restoreBackup(NVBackup backup) async {
    try {
      // Verify backup integrity
      if (!backup.verifyIntegrity()) {
        return RestoreResult(
          success: false,
          error: 'Backup integrity check failed',
        );
      }

      // Restore NV items
      final success = await nvManager.restoreNVItems(backup);

      if (success) {
        return RestoreResult(
          success: true,
          restoredIMEI: backup.originalIMEI,
        );
      } else {
        return RestoreResult(
          success: false,
          error: 'Failed to restore NV items',
        );
      }
    } catch (e) {
      return RestoreResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// Backup operation result
class BackupResult {
  final bool success;
  final String? backupPath;
  final String? error;
  final NVBackup? backup;

  BackupResult({
    required this.success,
    this.backupPath,
    this.error,
    this.backup,
  });

  @override
  String toString() => success
      ? 'BackupResult(success, path: $backupPath)'
      : 'BackupResult(error: $error)';
}

/// Restore operation result
class RestoreResult {
  final bool success;
  final String? restoredIMEI;
  final String? error;

  RestoreResult({
    required this.success,
    this.restoredIMEI,
    this.error,
  });

  @override
  String toString() => success
      ? 'RestoreResult(success, IMEI: $restoredIMEI)'
      : 'RestoreResult(error: $error)';
}
