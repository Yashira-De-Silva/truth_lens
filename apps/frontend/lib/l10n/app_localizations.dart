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

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No Messages Yet'**
  String get noMessagesYet;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with someone'**
  String get startConversation;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @thisMessageWasDeleted.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get thisMessageWasDeleted;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @startTheConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startTheConversation;

  /// No description provided for @selectUser.
  ///
  /// In en, this message translates to:
  /// **'Select User'**
  String get selectUser;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editMessage;

  /// No description provided for @deleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get deleteForMe;

  /// No description provided for @deleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get deleteForEveryone;

  /// No description provided for @messageEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get messageEdited;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopied;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get deleteMessageConfirm;

  /// No description provided for @deleteForMeDesc.
  ///
  /// In en, this message translates to:
  /// **'This message will be removed from this device only'**
  String get deleteForMeDesc;

  /// No description provided for @deleteForEveryoneDesc.
  ///
  /// In en, this message translates to:
  /// **'This message will be deleted for everyone in the chat'**
  String get deleteForEveryoneDesc;

  /// No description provided for @chatTheme.
  ///
  /// In en, this message translates to:
  /// **'Chat Theme'**
  String get chatTheme;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get classic;

  /// No description provided for @ocean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get ocean;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forest;

  /// No description provided for @lavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get lavender;

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnight;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuide;

  /// No description provided for @learnHowToUse.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use Truth Lens'**
  String get learnHowToUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @readPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readPrivacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @readTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get readTermsOfService;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// No description provided for @lastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get lastActive;

  /// No description provided for @removeDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove device'**
  String get removeDevice;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared successfully'**
  String get historyCleared;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likes;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @searchByKeyword.
  ///
  /// In en, this message translates to:
  /// **'Search by keyword'**
  String get searchByKeyword;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @userEmail.
  ///
  /// In en, this message translates to:
  /// **'user@example.com'**
  String get userEmail;

  /// No description provided for @managePreferredCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Preferred Categories'**
  String get managePreferredCategories;

  /// No description provided for @aiSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Summary'**
  String get aiSummary;

  /// No description provided for @fullArticle.
  ///
  /// In en, this message translates to:
  /// **'Full Article'**
  String get fullArticle;

  /// No description provided for @misinformationConfidence.
  ///
  /// In en, this message translates to:
  /// **'Misinformation Confidence'**
  String get misinformationConfidence;

  /// No description provided for @relatedTrustedSources.
  ///
  /// In en, this message translates to:
  /// **'Related trusted sources'**
  String get relatedTrustedSources;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms and conditions'**
  String get agreeToTerms;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get invalidPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @biased.
  ///
  /// In en, this message translates to:
  /// **'Biased'**
  String get biased;

  /// No description provided for @possiblyFake.
  ///
  /// In en, this message translates to:
  /// **'Possibly Fake'**
  String get possiblyFake;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @verifyNews.
  ///
  /// In en, this message translates to:
  /// **'Verify News'**
  String get verifyNews;

  /// No description provided for @newsTitle.
  ///
  /// In en, this message translates to:
  /// **'News Title (Optional)'**
  String get newsTitle;

  /// No description provided for @newsContent.
  ///
  /// In en, this message translates to:
  /// **'News Content'**
  String get newsContent;

  /// No description provided for @checkAuthenticity.
  ///
  /// In en, this message translates to:
  /// **'Check Authenticity'**
  String get checkAuthenticity;

  /// No description provided for @enterNewsContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter the news content to verify'**
  String get enterNewsContent;

  /// No description provided for @verificationResult.
  ///
  /// In en, this message translates to:
  /// **'Verification Result'**
  String get verificationResult;

  /// No description provided for @confidenceScore.
  ///
  /// In en, this message translates to:
  /// **'Confidence Score'**
  String get confidenceScore;

  /// No description provided for @viewSavedArticles.
  ///
  /// In en, this message translates to:
  /// **'View your saved articles'**
  String get viewSavedArticles;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @basicPlanUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Basic Plan - Upgrade now'**
  String get basicPlanUpgrade;

  /// No description provided for @funGames.
  ///
  /// In en, this message translates to:
  /// **'Fun & Games'**
  String get funGames;

  /// No description provided for @factVsFiction.
  ///
  /// In en, this message translates to:
  /// **'Fact vs Fiction'**
  String get factVsFiction;

  /// No description provided for @testVerificationSkills.
  ///
  /// In en, this message translates to:
  /// **'Test your news verification skills'**
  String get testVerificationSkills;

  /// No description provided for @newsQuizChallenge.
  ///
  /// In en, this message translates to:
  /// **'News Quiz Challenge'**
  String get newsQuizChallenge;

  /// No description provided for @testNewsLiteracy.
  ///
  /// In en, this message translates to:
  /// **'Test your news literacy knowledge'**
  String get testNewsLiteracy;

  /// No description provided for @chessGame.
  ///
  /// In en, this message translates to:
  /// **'Chess Game'**
  String get chessGame;

  /// No description provided for @playChess.
  ///
  /// In en, this message translates to:
  /// **'Play a classic game of chess'**
  String get playChess;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @previewProfile.
  ///
  /// In en, this message translates to:
  /// **'Preview My Profile'**
  String get previewProfile;

  /// No description provided for @seeProfilePreview.
  ///
  /// In en, this message translates to:
  /// **'See how others view your profile'**
  String get seeProfilePreview;

  /// No description provided for @logoutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutConfirmDesc;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @resources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I verify news articles?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Truth Lens uses advanced AI to analyze articles and provide credibility scores. Simply read any article and check the fact-check badge for verification status.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'What is the Digest feature?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Digest provides personalized daily news summaries based on your interests and reading habits. It helps you stay informed without information overload.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'How do I change my language?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Language and select your preferred language. Truth Lens supports English, Sinhala, and Tamil.'**
  String get faq3A;

  /// No description provided for @faq4Q.
  ///
  /// In en, this message translates to:
  /// **'How does the subscription work?'**
  String get faq4Q;

  /// No description provided for @faq4A.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription gives you unlimited access to all news sources, ad-free experience, advanced analytics, and priority support.'**
  String get faq4A;

  /// No description provided for @faq5Q.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get faq5Q;

  /// No description provided for @faq5A.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Privacy & Security > Manage Account to delete your account. Note that this action is permanent and cannot be undone.'**
  String get faq5A;

  /// No description provided for @findingTopVerifiedArticles.
  ///
  /// In en, this message translates to:
  /// **'Finding top verified articles...'**
  String get findingTopVerifiedArticles;

  /// No description provided for @couldNotLoadDigest.
  ///
  /// In en, this message translates to:
  /// **'Could not load digest'**
  String get couldNotLoadDigest;

  /// No description provided for @makeSureMlServiceRunning.
  ///
  /// In en, this message translates to:
  /// **'Make sure the ML service is running'**
  String get makeSureMlServiceRunning;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noVerifiedArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No verified articles found'**
  String get noVerifiedArticlesFound;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @avgConf.
  ///
  /// In en, this message translates to:
  /// **'Avg Conf'**
  String get avgConf;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @dataset.
  ///
  /// In en, this message translates to:
  /// **'Dataset'**
  String get dataset;

  /// No description provided for @liveNews.
  ///
  /// In en, this message translates to:
  /// **'Live News'**
  String get liveNews;

  /// No description provided for @fake.
  ///
  /// In en, this message translates to:
  /// **'Fake'**
  String get fake;

  /// No description provided for @uncertain.
  ///
  /// In en, this message translates to:
  /// **'Uncertain'**
  String get uncertain;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search for articles by keyword or category'**
  String get exploreSubtitle;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Make sure the ML service is running.'**
  String get verificationFailed;

  /// No description provided for @mlClassified.
  ///
  /// In en, this message translates to:
  /// **'ML classified'**
  String get mlClassified;
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
