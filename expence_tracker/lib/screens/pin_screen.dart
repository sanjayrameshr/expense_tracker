import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../utils/app_styles.dart';
import 'dashboard_screen.dart';

/// PocketPlan PIN entry / setup screen
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
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

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
    final pin = _pinController.text.trim();

    if (authProvider.isFirstRun) {
      final confirmPin = _confirmPinController.text.trim();
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
        await financeProvider.seedInitialData();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    } else {
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

    final gradient = LinearGradient(
      colors: [Colors.grey.shade100, Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon area
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 64,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    isFirstRun ? 'Set Your PIN' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFirstRun
                        ? 'Create a secure 4-digit PIN for your PocketPlan app'
                        : 'Enter your PIN to unlock PocketPlan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // PIN input fields
                  _pinField(
                    controller: _pinController,
                    label: isFirstRun ? 'Create PIN' : 'Enter PIN',
                    icon: Icons.pin_outlined,
                    obscureText: _obscurePin,
                    onToggleVisibility: () {
                      setState(() {
                        _obscurePin = !_obscurePin;
                      });
                    },
                  ),
                  if (isFirstRun) ...[
                    const SizedBox(height: 16),
                    _pinField(
                      controller: _confirmPinController,
                      label: 'Confirm PIN',
                      icon: Icons.pin_outlined,
                      obscureText: _obscureConfirmPin,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPin = !_obscureConfirmPin;
                        });
                      },
                    ),
                  ],

                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: AppButtonStyles.primaryLarge,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isFirstRun ? 'Set PIN' : 'Unlock',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (!isFirstRun)
                    TextButton.icon(
                      onPressed: () => _showResetDialog(context),
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      label: const Text('Forgot PIN?'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pinField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: obscureText,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F5F8),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset PIN'),
        content: const Text(
          'To reset your PIN, please clear app data or reinstall PocketPlan for your security.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
