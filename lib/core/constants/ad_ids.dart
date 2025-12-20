import 'dart:io';

class AdIds {
  // Test Ad IDs (for development)
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  // Production Ad IDs
  static const String _prodBannerAndroid = 'ca-app-pub-2246849300811913/6726530103';
  static const String _prodBannerIOS = 'ca-app-pub-2246849300811913/6902624076';
  static const String _prodInterstitialAndroid = 'ca-app-pub-2246849300811913/3825034592';
  static const String _prodInterstitialIOS = 'ca-app-pub-2246849300811913/9077361275';
  static const String _prodRewardedAndroid = 'ca-app-pub-2246849300811913/2811335820';
  static const String _prodRewardedIOS = 'ca-app-pub-2246849300811913/6918101793';

  // Set to false for production
  static const bool _useTestAds = false;

  // Banner Ad ID
  static String get bannerId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    return Platform.isAndroid ? _prodBannerAndroid : _prodBannerIOS;
  }

  // Interstitial Ad ID
  static String get interstitialId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIOS;
    }
    return Platform.isAndroid ? _prodInterstitialAndroid : _prodInterstitialIOS;
  }

  // Rewarded Ad ID
  static String get rewardedId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testRewardedAndroid : _testRewardedIOS;
    }
    return Platform.isAndroid ? _prodRewardedAndroid : _prodRewardedIOS;
  }
}
