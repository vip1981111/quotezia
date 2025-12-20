import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/ad_ids.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Set to true to hide ads for screenshots
  static const bool hideAdsForScreenshots = true;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  int _quoteViewCount = 0;
  static const int _interstitialFrequency = 5;

  bool get isBannerAdLoaded => hideAdsForScreenshots ? false : _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  Future<void> initialize() async {
    // Only initialize on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('AdService: Ads not supported on this platform');
      return;
    }

    await MobileAds.instance.initialize();
    debugPrint('AdService: MobileAds initialized');

    // Load initial ads
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // Banner Ad
  void loadBannerAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _bannerAd = BannerAd(
      adUnitId: AdIds.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdService: Banner ad loaded');
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner ad failed to load: ${error.message}');
          ad.dispose();
          _isBannerAdLoaded = false;
          // Retry loading after delay
          Future.delayed(const Duration(seconds: 30), loadBannerAd);
        },
        onAdOpened: (ad) => debugPrint('AdService: Banner ad opened'),
        onAdClosed: (ad) => debugPrint('AdService: Banner ad closed'),
      ),
    );

    _bannerAd!.load();
  }

  // Interstitial Ad
  void loadInterstitialAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    InterstitialAd.load(
      adUnitId: AdIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdService: Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdService: Interstitial ad failed to show: ${error.message}');
              ad.dispose();
              _isInterstitialAdLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdLoaded = false;
          // Retry loading after delay
          Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
        },
      ),
    );
  }

  // Rewarded Ad
  void loadRewardedAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    RewardedAd.load(
      adUnitId: AdIds.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdService: Rewarded ad loaded');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Rewarded ad failed to load: ${error.message}');
          _isRewardedAdLoaded = false;
          // Retry loading after delay
          Future.delayed(const Duration(seconds: 30), loadRewardedAd);
        },
      ),
    );
  }

  // Show Interstitial Ad
  Future<bool> showInterstitialAd() async {
    if (hideAdsForScreenshots) return false;
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      debugPrint('AdService: Interstitial ad not ready');
      return false;
    }

    await _interstitialAd!.show();
    return true;
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd({
    required Function(int amount) onRewarded,
  }) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      debugPrint('AdService: Rewarded ad not ready');
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: Rewarded ad dismissed');
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
        onRewarded(reward.amount.toInt());
      },
    );

    return true;
  }

  // Track quote views and show interstitial every N quotes
  void onQuoteViewed() {
    _quoteViewCount++;
    debugPrint('AdService: Quote view count: $_quoteViewCount');

    if (_quoteViewCount >= _interstitialFrequency) {
      _quoteViewCount = 0;
      showInterstitialAd();
    }
  }

  // Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
