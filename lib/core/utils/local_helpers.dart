import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

/// Helps in making the code more readable, clean and maintainable by accessing the translations
/// **directly from the `context`**, so instead of using `AppLocalizations.of(context).blabla`, and having to import
/// that class from wherever it happened to be, just use `context.loc.blabla`... Magic!
extension L10nHelper on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}


/// This calculates the percentage of difference from [oldValue] to [newValue]
double calculatePercentageIncrease(int oldValue, int newValue) {
  if (oldValue == 0) return double.infinity; // avoid division by zero
  return (((newValue - oldValue) / oldValue) * 100).roundToDouble().abs();
}