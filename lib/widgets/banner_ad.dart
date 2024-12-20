import 'package:flutter/material.dart';
import 'package:gandalf/Ads.dart';
import 'package:gandalf/configs/app.dart';
import 'package:gandalf/constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({Key? key}) : super(key: key);

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  bool isAdLoaded = false;
  BannerAd? ad;

  @override
  void initState() {
    super.initState();

    if (!App.showAds) return;

    this.ad = BannerAd(
      adUnitId: Ads.banner(),
      size: AdSize.largeBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    this.ad?.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!App.showAds || !this.isAdLoaded) {
      return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: PADDING * 2),
      child: SizedBox(
        height: this.ad?.size.height.toDouble(),
        width: this.ad?.size.width.toDouble(),
        child: this.isAdLoaded ? AdWidget(ad: this.ad!) : SizedBox(),
      ),
    );
  }
}
