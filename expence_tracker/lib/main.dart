import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/user_settings.dart';
import 'models/transaction.dart';
import 'models/loan.dart';
import 'models/fees_goal.dart';
import 'models/budget.dart';
import 'providers/auth_provider.dart';
import 'providers/finance_provider.dart';
import 'services/storage_service.dart';
import 'screens/pin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Optimize memory and performance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(TransactionCategoryAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(LoanAdapter());
  Hive.registerAdapter(LoanPaymentAdapter());
  Hive.registerAdapter(FeesGoalAdapter());
  Hive.registerAdapter(BudgetAdapter());

  runApp(const PocketPlanApp());
}

class PocketPlanApp extends StatelessWidget {
  const PocketPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<StorageService>())..initialize(),
        ),
        ChangeNotifierProvider<FinanceProvider>(
          create: (context) => FinanceProvider(context.read<StorageService>()),
        ),
      ],
      child: MaterialApp(
        title: 'PocketPlan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          cardTheme: const CardThemeData(elevation: 2),
          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        home: const PinScreen(),
      ),
    );
  }
}
