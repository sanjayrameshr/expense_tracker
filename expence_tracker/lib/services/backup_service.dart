import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user_settings.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../models/fees_goal.dart';

/// Service for backup and restore operations
class BackupService {
  /// Export all data to JSON
  Future<String> exportData({
    required UserSettings? settings,
    required List<Transaction> transactions,
    required List<Loan> loans,
    required List<FeesGoal> feesGoals,
  }) async {
    final data = {
      'version': '1.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'settings': settings?.toJson(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'loans': loans.map((l) => l.toJson()).toList(),
      'feesGoals': feesGoals.map((g) => g.toJson()).toList(),
    };

    return jsonEncode(data);
  }

  /// Parse imported JSON data
  Map<String, dynamic> parseImportData(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    return {
      'settings':
          data['settings'] != null
              ? UserSettings.fromJson(data['settings'] as Map<String, dynamic>)
              : null,
      'transactions':
          (data['transactions'] as List)
              .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
              .toList(),
      'loans':
          (data['loans'] as List)
              .map((l) => Loan.fromJson(l as Map<String, dynamic>))
              .toList(),
      'feesGoals':
          (data['feesGoals'] as List)
              .map((g) => FeesGoal.fromJson(g as Map<String, dynamic>))
              .toList(),
    };
  }

  /// Save backup to file
  Future<String> saveBackupToFile(String jsonData) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/pocketplan_backup_$timestamp.json');
    await file.writeAsString(jsonData);
    return file.path;
  }

  /// Read backup from file path
  Future<String> readBackupFromFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }
}
