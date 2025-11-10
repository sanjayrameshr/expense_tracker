import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';
import '../utils/app_styles.dart';

/// Settings screen — simple, calm, and consistent with PocketPlan's modern UI
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF8F9FB);
    final tileColor = Colors.white;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: background,
        elevation: 0,
        foregroundColor: Colors.grey.shade800,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Backup & Restore'),
          _SettingsCard(
            tileColor: tileColor,
            children: [
              _settingsTile(
                context,
                icon: Icons.upload_rounded,
                title: 'Export Data',
                subtitle: 'Backup all data to JSON file',
                onTap: () => _exportData(context),
              ),
              _settingsTile(
                context,
                icon: Icons.download_rounded,
                title: 'Import Data',
                subtitle: 'Restore data from JSON backup',
                onTap: () => _importData(context),
              ),
            ],
          ),
          _SectionHeader(title: 'Security'),
          _SettingsCard(
            tileColor: tileColor,
            children: [
              _settingsTile(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Change PIN',
                subtitle: 'Update your app security PIN',
                onTap: () => _changePin(context),
              ),
            ],
          ),
          _SectionHeader(title: 'Quick Actions'),
          _SettingsCard(
            tileColor: tileColor,
            children: [
              _settingsTile(
                context,
                icon: Icons.payment_rounded,
                title: 'Open GPay',
                subtitle: 'Launch Google Pay app',
                onTap: () => _openGPay(context),
              ),
            ],
          ),
          _SectionHeader(title: 'Data Management'),
          _SettingsCard(
            tileColor: tileColor,
            children: [
              _settingsTile(
                context,
                icon: Icons.add_circle_outline_rounded,
                title: 'Load Sample Data',
                subtitle: 'Add sample transactions and budgets',
                iconColor: Colors.green.shade600,
                onTap: () => _loadSampleData(context),
              ),
            ],
          ),
          _SectionHeader(title: 'Danger Zone'),
          _SettingsCard(
            tileColor: tileColor,
            children: [
              _settingsTile(
                context,
                icon: Icons.delete_forever_rounded,
                title: 'Reset All Data',
                subtitle: 'Delete all transactions, loans, and goals',
                iconColor: Colors.red.shade600,
                textColor: Colors.red.shade700,
                onTap: () => _resetData(context),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// --- UI Components ---
  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey.shade700).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Colors.grey.shade700, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.grey.shade900,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  /// Wrapper card grouping related settings
  Widget _SettingsCard(
      {required List<Widget> children, required Color tileColor}) {
    return Card(
      color: tileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 0, thickness: 0.6, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }

  /// --- Action Implementations ---

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
            backgroundColor: Colors.grey.shade800,
            content: Text('✅ Backup saved to:\n$filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final controller = TextEditingController();

    final filePath = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: AppButtonStyles.primaryElevated,
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
      await finance.clearAllData();

      for (var txn in data['transactions']) await storage.saveTransaction(txn);
      for (var loan in data['loans']) await storage.saveLoan(loan);
      for (var goal in data['feesGoals']) await storage.saveFeesGoal(goal);

      await finance.loadData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Data imported successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> _changePin(BuildContext context) async {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            const SizedBox(height: 12),
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
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppButtonStyles.primaryElevated,
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final auth = context.read<AuthProvider>();
    final success =
        await auth.changePin(oldPinController.text, newPinController.text);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            success ? '✅ PIN changed successfully' : 'Failed to change PIN'),
      ));
    }
  }

  Future<void> _openGPay(BuildContext context) async {
    final uri = Uri.parse('gpay://');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final playStoreUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.google.android.apps.nbu.paisa.user',
        );
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open GPay: $e')));
      }
    }
  }

  Future<void> _loadSampleData(BuildContext context) async {
    final confirm = await _confirmDialog(
      context,
      title: 'Load Sample Data',
      content: 'This will add ₹20,000 cash, ₹1.1L loan, and sample budgets.\n'
          'Existing data will not be deleted.',
      confirmText: 'Load',
      confirmColor: Colors.green,
    );

    if (confirm != true) return;

    final finance = context.read<FinanceProvider>();
    await finance.seedInitialData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Sample data loaded successfully!'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final confirm = await _confirmDialog(
      context,
      title: 'Reset All Data',
      content:
          'Are you sure you want to delete all data?\nThis action cannot be undone.',
      confirmText: 'Reset',
      confirmColor: Colors.red,
    );

    if (confirm != true) return;

    final finance = context.read<FinanceProvider>();
    await finance.clearAllData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data has been reset')));
    }
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

/// Clean section header for logical grouping
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
