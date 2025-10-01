import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  // Format angka jadi Rupiah, misal 1000 -> Rp 1.000
  static String format(int value) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  // Parse string Rupiah ke angka, misal 'Rp 1.000' -> 1000
  static int parse(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // InputFormatter buat TextFormField
  static TextInputFormatter inputFormatter() => _CurrencyInputFormatter();
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    String formatted = _formatter.format(int.parse(digitsOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PriceInput extends StatelessWidget {
  final Map roomType;
  final String periodType;
  final String label;

  const PriceInput({
    required this.roomType,
    required this.periodType,
    required this.label,
    super.key,
  });

  double _getPrice() {
    return (roomType['prices'] as List)
            .firstWhere((p) => p['period_type'] == periodType,
                orElse: () => {'price': 0})['price']
            ?.toDouble() ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
          .format(_getPrice()),
    );

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (val) => val!.isEmpty ? '$label tidak boleh kosong' : null,
      onChanged: (val) {
        double parsed =
            double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

        if ((roomType['prices'] as List)
            .any((p) => p['period_type'] == periodType)) {
          (roomType['prices'] as List)
                  .firstWhere((p) => p['period_type'] == periodType)['price'] =
              parsed;
        } else {
          (roomType['prices'] as List).add({
            'period_type': periodType,
            'price': parsed,
          });
        }

        // Update controller text agar otomatis format Rupiah
        controller.value = controller.value.copyWith(
          text: NumberFormat.currency(
                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
              .format(parsed),
          selection: TextSelection.collapsed(offset: controller.text.length),
        );
      },
    );
  }
}
