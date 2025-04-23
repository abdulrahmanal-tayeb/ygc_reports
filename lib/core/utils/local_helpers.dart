import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

extension L10nHelper on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
  
}