import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';

/// Settings screen with backup, PIN change, and reset options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Backup & Restore'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Data'),
            subtitle: const Text('Backup all data to JSON file'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            subtitle: const Text('Restore data from JSON file'),
            onTap: () => _importData(context),
          ),
          const Divider(),
          const _SectionHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change PIN'),
            onTap: () => _changePin(context),
          ),
          const Divider(),
          const _SectionHeader(title: 'Quick Actions'),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Open GPay'),
            subtitle: const Text('Launch Google Pay app'),
            onTap: () => _openGPay(context),
          ),
          const Divider(),
          const _SectionHeader(title: 'Danger Zone'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset All Data'),
            subtitle: const Text('Delete all transactions, loans, and goals'),
            textColor: Colors.red,
            onTap: () => _resetData(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final storage = StorageService();
      final backupService = BackupService();

      final settings = await storage.getUserSettings();
      final transactions = await storage.getTransactions();
      final loans = await storage.getLoans();
      final feesGoals = await storage.getFeesGoals();

      final jsonData = await backupService.exportData(
        settings: settings,
        transactions: transactions,
        loans: loans,
        feesGoals: feesGoals,
      );

      final filePath = await backupService.saveBackupToFile(jsonData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved to:\n$filePath'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    // In a real app, you'd use file_picker package to select a file
    // For this scaffold, we'll show a dialog to enter file path
    final controller = TextEditingController();

    final filePath = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Import Data'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'File Path',
                hintText: '/path/to/backup.json',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Import'),
              ),
            ],
          ),
    );

    if (filePath == null || filePath.isEmpty) return;

    try {
      final backupService = BackupService();
      final jsonData = await backupService.readBackupFromFile(filePath);
      final data = backupService.parseImportData(jsonData);

      final storage = StorageService();
      final finance = context.read<FinanceProvider>();

      // Clear existing data
      await finance.clearAllData();

      // Import transactions
      for (var txn in data['transactions']) {
        await storage.saveTransaction(txn);
      }

      // Import loans
      for (var loan in data['loans']) {
        await storage.saveLoan(loan);
      }

      // Import goals
      for (var goal in data['feesGoals']) {
        await storage.saveFeesGoal(goal);
      }

      await finance.loadData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> _changePin(BuildContext context) async {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPinController,
                  decoration: const InputDecoration(labelText: 'Current PIN'),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: newPinController,
                  decoration: const InputDecoration(labelText: 'New PIN'),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Change'),
              ),
            ],
          ),
    );

    if (result != true) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.changePin(
      oldPinController.text,
      newPinController.text,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'PIN changed successfully' : 'Failed to change PIN',
          ),
        ),
      );
    }
  }

  Future<void> _openGPay(BuildContext context) async {
    // GPay URL scheme
    final uri = Uri.parse('gpay://');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to Play Store
        final playStoreUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.google.android.apps.nbu.paisa.user',
        );
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open GPay: $e')));
      }
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset All Data'),
            content: const Text(
              'Are you sure you want to delete all data? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final finance = context.read<FinanceProvider>();
    await finance.clearAllData();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All data has been reset')));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
