import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/settings_provider.dart';
import 'app_localizations.dart';

final localizationsProvider = Provider<AppLocalizations>((ref) {
  final languageCode = ref.watch(settingsProvider).language;
  return AppLocalizations(languageCode);
});
