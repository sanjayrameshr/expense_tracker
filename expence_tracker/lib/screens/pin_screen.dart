import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import 'dashboard_screen.dart';

/// PIN entry screen for authentication
class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProvider = context.read<AuthProvider>();
    final financeProvider = context.read<FinanceProvider>();
    final pin = _pinController.text;

    if (authProvider.isFirstRun) {
      // Set new PIN
      final confirmPin = _confirmPinController.text;
      if (pin != confirmPin) {
        setState(() {
          _errorMessage = 'PINs do not match';
          _isLoading = false;
        });
        return;
      }

      if (pin.length < 4) {
        setState(() {
          _errorMessage = 'PIN must be at least 4 digits';
          _isLoading = false;
        });
        return;
      }

      final success = await authProvider.setPin(pin);
      if (success) {
        // Seed initial data on first run
        await financeProvider.seedInitialData();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    } else {
      // Verify existing PIN
      final success = await authProvider.verifyPin(pin);
      if (success) {
        await financeProvider.initialize();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isFirstRun = authProvider.isFirstRun;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                isFirstRun ? 'Set Your PIN' : 'Enter PIN',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isFirstRun
                    ? 'Create a 4-digit PIN to secure your data'
                    : 'Enter your PIN to access PocketPlan',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: isFirstRun ? 'Create PIN' : 'Enter PIN',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.pin),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
              ),
              if (isFirstRun) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPinController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm PIN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pin),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                ),
              ],
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(isFirstRun ? 'Set PIN' : 'Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
