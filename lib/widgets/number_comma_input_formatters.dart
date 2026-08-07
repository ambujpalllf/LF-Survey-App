import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberCommaInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('hi_IN');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all commas
    String raw = newValue.text.replaceAll(",", "");

    if (raw.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Prevent more than 9 digits
    if (raw.length > 9) return oldValue;

    // Format number with Indian commas
    String formatted = _formatter.format(int.parse(raw));

    // Maintain cursor position
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
