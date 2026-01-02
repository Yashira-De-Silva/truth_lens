import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/settings_provider.dart';
import 'app_localizations.dart';

// Provider to get current localizations based on selected language
final localizationsProvider = Provider<AppLocalizations>((ref) {
  final languageCode = ref.watch(settingsProvider).language;
  return AppLocalizations(languageCode);
});
