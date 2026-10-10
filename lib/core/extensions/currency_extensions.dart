import 'package:intl/intl.dart';

extension CurrencyFormatting on num {
  String toNaira({bool showDecimals = false}) {
    final format = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: showDecimals ? 2 : 0,
    );
    return format.format(this);
  }

  String get currencyFormat => toNaira();
}

extension CurrencyStringFormatting on String {
  String toNaira({bool showDecimals = false}) {
    final value = double.tryParse(this) ?? 0;
    return value.toNaira(showDecimals: showDecimals);
  }

  String get currencyFormat => toNaira();
}
