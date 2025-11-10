import 'package:intl/intl.dart';

/// Format double value as Indian Rupee currency
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Format date as dd MMM yyyy
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

/// Format date with time
String formatDateTime(DateTime date) {
  return DateFormat('dd MMM yyyy, hh:mm a').format(date);
}
