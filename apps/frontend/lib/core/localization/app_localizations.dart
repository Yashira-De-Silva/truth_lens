class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String languageCode) {
    return AppLocalizations(languageCode);
  }

  String get newsFeed => _translate('News Feed', 'ප්‍රවෘත්ති සංග්‍රහය', 'செய்தி ஊட்டம்');
  String get explore => _translate('Explore', 'ගවේෂණය', 'ஆராய்');
  String get digest => _translate('Digest', 'සාරාංශය', 'சுருக்கம்');
  String get bookmarks => _translate('Bookmarks', 'පොත් සලකුණු', 'புக்மார்க்குகள்');
  String get profile => _translate('Profile', 'පැතිකඩ', 'சுயவிவரம்');

  String get manageAccount => _translate('Manage your account settings', 'ඔබගේ ගිණුම් සැකසීම් කළමනාකරණය කරන්න', 'உங்கள் கணக்கு அமைப்புகளை நிர்வகிக்கவும்');
  String get premiumUser => _translate('Premium User', 'වාසි සහිත පරිශීලක', 'சிறப்பு பயனர்');
  String get preferences => _translate('Preferences', 'මනාපයන්', 'விருப்பங்கள்');
  String get notifications => _translate('Notifications', 'දැනුම්දීම්', 'அறிவிப்புகள்');
  String get notificationsSubtitle => _translate('Get latest news alerts', 'නවතම ප්‍රවෘත්ති ඇඟවීම් ලබා ගන්න', 'சமீபத்திய செய்தி விழிப்பூட்டல்களைப் பெறுங்கள்');
  String get preferredCategories => _translate('Preferred Categories', 'කැමති ප්‍රවර්ග', 'விருப்பமான வகைகள்');
  String get customizeNewsFeed => _translate('Customize your news feed', 'ඔබගේ ප්‍රවෘත්ති සංග්‍රහය අභිරුචිකරණය කරන්න', 'உங்கள் செய்தி ஊட்டத்தை தனிப்பயனாக்குங்கள்');
  
  String get account => _translate('Account', 'ගිණුම', 'கணக்கு');
  String get privacySecurity => _translate('Privacy & Security', 'පෞද්ගලිකත්වය සහ ආරක්ෂාව', 'தனியுரிமை மற்றும் பாதுகாப்பு');
  String get privacySettings => _translate('Manage your privacy settings', 'ඔබගේ පෞද්ගලිකත්ව සැකසීම් කළමනාකරණය කරන්න', 'உங்கள் தனியுரிமை அமைப்புகளை நிர்வகிக்கவும்');
  String get language => _translate('Language', 'භාෂාව', 'மொழி');
  
  String get about => _translate('About', 'පිළිබඳව', 'பற்றி');
  String get help => _translate('Help & Support', 'උදව් සහ සහාය', 'உதவி மற்றும் ஆதரவு');
  String get getHelp => _translate('Get help and support', 'උදව් සහ සහාය ලබා ගන්න', 'உதவி மற்றும் ஆதரவு பெறுங்கள்');
  String get aboutApp => _translate('About TruthLens', 'TruthLens ගැන', 'TruthLens பற்றி');
  String get appInfo => _translate('App version and information', 'යෙදුම් අනුවාදය සහ තොරතුරු', 'பயன்பாட்டு பதிப்பு மற்றும் தகவல்');
  String get logout => _translate('Log Out', 'ඉවත් වන්න', 'வெளியேறு');
  String get logoutAccount => _translate('Sign out of your account', 'ඔබගේ ගිණුමෙන් ඉවත් වන්න', 'உங்கள் கணக்கிலிருந்து வெளியேறு');

  // Edit Profile
  String get editProfile => _translate('Edit Profile', 'පැතිකඩ සංස්කරණය කරන්න', 'சுயவிவரத்தைத் திருத்து');
  String get updateInfo => _translate('Update your information', 'ඔබගේ තොරතුරු යාවත්කාලීන කරන්න', 'உங்கள் தகவலை புதுப்பிக்கவும்');
  String get fullName => _translate('Full Name', 'සම්පූර්ණ නම', 'முழு பெயர்');
  String get email => _translate('Email', 'විද්‍යුත් තැපෑල', 'மின்னஞ்சல்');
  String get phoneNumber => _translate('Phone Number', 'දුරකථන අංකය', 'தொலைபேசி எண்');
  String get bio => _translate('Bio', 'ජීව දත්ත', 'சுயவிவரம்');
  String get saveChanges => _translate('Save Changes', 'වෙනස්කම් සුරකින්න', 'மாற்றங்களை சேமி');
  String get profileUpdated => _translate('Profile updated successfully!', 'පැතිකඩ සාර්ථකව යාවත්කාලීන කරන ලදී!', 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!');

  // Language Screen
  String get selectLanguage => _translate('Select your preferred language', 'ඔබගේ කැමති භාෂාව තෝරන්න', 'உங்கள் விருப்பமான மொழியை தேர்ந்தெடுக்கவும்');
  String get languageChanged => _translate('Language changed to', 'භාෂාව වෙනස් කරන ලදී', 'மொழி மாற்றப்பட்டது');

  // Privacy & Security Screen
  String get managePrivacy => _translate('Manage your privacy and security settings', 'ඔබගේ පෞද්ගලිකත්වය සහ ආරක්ෂණ සැකසීම් කළමනාකරණය කරන්න', 'உங்கள் தனியுரிமை மற்றும் பாதுகாப்பு அமைப்புகளை நிர்வகிக்கவும்');
  String get privacy => _translate('Privacy', 'පෞද්ගලිකත්වය', 'தனியுரிமை');
  String get security => _translate('Security', 'ආරක්ෂාව', 'பாதுகாப்பு');
  String get profileVisibility => _translate('Profile Visibility', 'පැතිකඩ දෘශ්‍යතාව', 'சுயவிவர தெரிவுநிலை');
  String get controlVisibility => _translate('Control who can see your profile', 'ඔබගේ පැතිකඩ කාටද දැකිය හැකිද යන්න පාලනය කරන්න', 'உங்கள் சுயவிவரத்தை யார் பார்க்க முடியும் என்பதைக் கட்டுப்படுத்துங்கள்');
  String get readingHistory => _translate('Reading History', 'කියවීමේ ඉතිහාසය', 'வாசிப்பு வரலாறு');
  String get manageHistory => _translate('Manage your article history', 'ඔබගේ ලිපි ඉතිහාසය කළමනාකරණය කරන්න', 'உங்கள் கட்டுரை வரலாற்றை நிர்வகிக்கவும்');
  String get clearData => _translate('Clear Data', 'දත්ත මකන්න', 'தரவை அழி');
  String get removeCachedData => _translate('Remove cached articles and data', 'හැඹිලිගත ලිපි සහ දත්ත ඉවත් කරන්න', 'தற்காலிக கட்டுரைகள் மற்றும் தரவை அகற்று');
  String get changePassword => _translate('Change Password', 'මුරපදය වෙනස් කරන්න', 'கடவுச்சொல்லை மாற்று');
  String get updatePassword => _translate('Update your password', 'ඔබගේ මුරපදය යාවත්කාලීන කරන්න', 'உங்கள் கடவுச்சொல்லை புதுப்பிக்கவும்');
  String get biometricAuth => _translate('Biometric Authentication', 'ජීවමිතික සත්‍යාපනය', 'உயிரியல் அங்கீகாரம்');
  String get useBiometric => _translate('Use fingerprint or face ID', 'ඇඟිලි සලකුණ හෝ මුහුණු හැඳුනුම්පත භාවිතා කරන්න', 'கைரேகை அல்லது முக அடையாளத்தைப் பயன்படுத்துங்கள்');
  String get manageDevices => _translate('Manage Devices', 'උපාංග කළමනාකරණය කරන්න', 'சாதனங்களை நிர்வகிக்கவும்');
  String get seeDevices => _translate('See devices where you\'re logged in', 'ඔබ පුරනය වී සිටින උපාංග බලන්න', 'நீங்கள் உள்நுழைந்துள்ள சாதனங்களைக் காண்க');

  // News Feed
  String get verified => _translate('Verified', 'සත්‍යාපිත', 'சரிபார்க்கப்பட்டது');
  String get unverified => _translate('Unverified', 'අසත්‍යාපිත', 'சரிபார்க்கப்படவில்லை');
  String get suspicious => _translate('Suspicious', 'සැක සහිත', 'சந்தேகத்திற்குரிய');
  String get read => _translate('Read', 'කියවන්න', 'படிக்கவும்');
  String get save => _translate('Save', 'සුරකින්න', 'சேமிக்கவும்');
  String get unsave => _translate('Unsave', 'සුරැකීම ඉවත් කරන්න', 'நீக்கவும்');

  // Search
  String get searchNews => _translate('Search news articles...', 'ප්‍රවෘත්ති ලිපි සොයන්න...', 'செய்திக் கட்டுரைகளைத் தேடு...');
  String get allCategories => _translate('All', 'සියල්ල', 'அனைத்தும்');
  String get politics => _translate('Politics', 'දේශපාලනය', 'அரசியல்');
  String get technology => _translate('Technology', 'තාක්ෂණය', 'தொழில்நுட்பம்');
  String get sports => _translate('Sports', 'ක්‍රීඩා', 'விளையாட்டு');
  String get business => _translate('Business', 'ව්‍යාපාර', 'வணிகம்');
  String get health => _translate('Health', 'සෞඛ්‍යය', 'சுகாதாரம்');
  String get entertainment => _translate('Entertainment', 'විනෝදාස්වාදය', 'பொழுதுபோக்கு');
  String get science => _translate('Science', 'විද්‍යාව', 'அறிவியல்');

  // Digest
  String get topVerified => _translate('Top 3 Verified News', 'ඉහළ සත්‍යාපිත ප්‍රවෘත්ති 3', 'சிறந்த 3 சரிபார்க்கப்பட்ட செய்திகள்');
  String get todayDigest => _translate('Today\'s most trusted stories', 'අද විශ්වාසදායකම කතන්දර', 'இன்றைய மிகவும் நம்பகமான செய்திகள்');

  // Bookmarks
  String get savedArticles => _translate('Saved Articles', 'සුරකින ලද ලිපි', 'சேமிக்கப்பட்ட கட்டுரைகள்');
  String get noBookmarks => _translate('No bookmarks yet', 'තවමත් පොත් සලකුණු නැත', 'இன்னும் புக்மார்க்குகள் இல்லை');
  String get startSaving => _translate('Start saving articles to read later', 'පසුව කියවීමට ලිපි සුරැකීම ආරම්භ කරන්න', 'பின்னர் படிக்க கட்டுரைகளை சேமிக்கத் தொடங்குங்கள்');

  // Common
  String get back => _translate('Back', 'ආපසු', 'பின்னால்');
  String get cancel => _translate('Cancel', 'අවලංගු කරන්න', 'ரத்துசெய்');
  String get confirm => _translate('Confirm', 'තහවුරු කරන්න', 'உறுதிப்படுத்து');
  String get delete => _translate('Delete', 'මකන්න', 'அழி');
  String get edit => _translate('Edit', 'සංස්කරණය', 'திருத்து');

  // Helper method to translate
  String _translate(String en, String si, String ta) {
    switch (languageCode) {
      case 'si':
        return si;
      case 'ta':
        return ta;
      default:
        return en;
    }
  }
}
