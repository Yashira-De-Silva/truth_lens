import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @newsFeed.
  ///
  /// In en, this message translates to:
  /// **'News Feed'**
  String get newsFeed;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @digest.
  ///
  /// In en, this message translates to:
  /// **'Digest'**
  String get digest;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage your account settings'**
  String get manageAccount;

  /// No description provided for @premiumUser.
  ///
  /// In en, this message translates to:
  /// **'Premium User'**
  String get premiumUser;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get latest news alerts'**
  String get notificationsSubtitle;

  /// No description provided for @preferredCategories.
  ///
  /// In en, this message translates to:
  /// **'Preferred Categories'**
  String get preferredCategories;

  /// No description provided for @customizeNewsFeed.
  ///
  /// In en, this message translates to:
  /// **'Customize your news feed'**
  String get customizeNewsFeed;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get privacySettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelp;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About TruthLens'**
  String get aboutApp;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get appInfo;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logoutAccount;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get updateInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChanged;

  /// No description provided for @managePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy and security settings'**
  String get managePrivacy;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @profileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile Visibility'**
  String get profileVisibility;

  /// No description provided for @controlVisibility.
  ///
  /// In en, this message translates to:
  /// **'Control who can see your profile'**
  String get controlVisibility;

  /// No description provided for @readingHistory.
  ///
  /// In en, this message translates to:
  /// **'Reading History'**
  String get readingHistory;

  /// No description provided for @manageHistory.
  ///
  /// In en, this message translates to:
  /// **'Manage your article history'**
  String get manageHistory;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @removeCachedData.
  ///
  /// In en, this message translates to:
  /// **'Remove cached articles and data'**
  String get removeCachedData;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get updatePassword;

  /// No description provided for @biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuth;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID'**
  String get useBiometric;

  /// No description provided for @manageDevices.
  ///
  /// In en, this message translates to:
  /// **'Manage Devices'**
  String get manageDevices;

  /// No description provided for @seeDevices.
  ///
  /// In en, this message translates to:
  /// **'See devices where you\'re logged in'**
  String get seeDevices;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @suspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get suspicious;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @unsave.
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsave;

  /// No description provided for @searchNews.
  ///
  /// In en, this message translates to:
  /// **'Search news articles...'**
  String get searchNews;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @politics.
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get politics;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @topVerified.
  ///
  /// In en, this message translates to:
  /// **'Top 3 Verified News'**
  String get topVerified;

  /// No description provided for @todayDigest.
  ///
  /// In en, this message translates to:
  /// **'Today\'s most trusted stories'**
  String get todayDigest;

  /// No description provided for @savedArticles.
  ///
  /// In en, this message translates to:
  /// **'Saved Articles'**
  String get savedArticles;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarks;

  /// No description provided for @startSaving.
  ///
  /// In en, this message translates to:
  /// **'Start saving articles to read later'**
  String get startSaving;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @savedToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Saved to bookmarks'**
  String get savedToBookmarks;

  /// No description provided for @removedFromBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Removed from bookmarks'**
  String get removedFromBookmarks;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found for'**
  String get noResultsFound;

  /// No description provided for @imagePickerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Image picker coming soon!'**
  String get imagePickerComingSoon;

  /// No description provided for @categoriesSelected.
  ///
  /// In en, this message translates to:
  /// **'categories selected'**
  String get categoriesSelected;

  /// No description provided for @categorySelected.
  ///
  /// In en, this message translates to:
  /// **'category selected'**
  String get categorySelected;

  /// No description provided for @shareArticle.
  ///
  /// In en, this message translates to:
  /// **'Share Article'**
  String get shareArticle;

  /// No description provided for @reportArticle.
  ///
  /// In en, this message translates to:
  /// **'Report Article'**
  String get reportArticle;

  /// No description provided for @notInterested.
  ///
  /// In en, this message translates to:
  /// **'Not Interested'**
  String get notInterested;

  /// No description provided for @shareFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon!'**
  String get shareFeatureComingSoon;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSubmitted;

  /// No description provided for @articleHidden.
  ///
  /// In en, this message translates to:
  /// **'Article hidden from feed'**
  String get articleHidden;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
