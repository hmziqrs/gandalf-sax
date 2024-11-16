import 'dart:ui' as ui;

import 'package:flutter/material.dart';


import 'package:gandalf/constants.dart';
import 'package:gandalf/Utils.dart';
import 'package:gandalf/Ads.dart';

import 'package:gandalf/widgets/Buttons/Alpha.dart';
import 'package:provider/provider.dart';

import 'Space.dart';

class HomeBottomSheet extends StatelessWidget {
  void doDonate(BuildContext context) {

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Test"),
          content: Text("Test."),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Donate"),
              onPressed: () async {
                // final result =
                //     await InAppPurchaseConnection.instance.buyNonConsumable(
                //   purchaseParam: purchaseParam,
                // );
                // if (result) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text("Thank You! for donating."),
                //     ),
                //   );
                // }
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final divider = Divider(
      height: 0,
      thickness: 2.0,
      color: Colors.black.withOpacity(0.08),
    );

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 8,
              sigmaY: 8,
            ),
            child: Align(
              child: Container(
                width: size.width * 0.8,
                height: size.height * 0.8,
                constraints: BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (n) {
                    n.disallowIndicator();
                    return true;
                  },
                  child: ListView(
                    children: [
                      SizedBox(height: PADDING * 2),
                      Space(
                        child: Text(
                          "Epic Sax Gandalf Infinite",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: PADDING * 0.5),
                      Space(
                        child: Text(
                          "It's just gandalf an epic one",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ),
                      SizedBox(height: PADDING * 2),
                      divider,
                      SizedBox(height: PADDING * 2),
                      // Container(
                      //   height: 80,
                      //   width: double.infinity,
                      //   child: AdmobBanner(
                      //     // adUnitId: Ads.banner(),
                      //     adSize: AdmobBannerSize.FULL_BANNER,
                      //     adUnitId: Ads.banner(),
                      //   ),
                      // ),
                      SizedBox(height: PADDING * 2),
                      // Space(
                      //   child: AlphaButton(
                      //     onTap: () => Utils.launchUrl(
                      //       "https://www.youtube.com/watch?v=BBGEG21CGo0",
                      //     ),
                      //     label: "Original Video",
                      //     icon: MaterialCommunityIcons.youtube,
                      //   ),
                      // ),
                      SizedBox(height: PADDING * 2),
                      Space(
                        child: Text(
                          "Donations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            // color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ),
                      SizedBox(height: PADDING * 2),
                      // !state.loading
                      //     ? Space(
                      //         child: Row(
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           children: state.products
                      //               .map(
                      //                 (product) => AlphaButton(
                      //                   label: product.price,
                      //                   onTap: () =>
                      //                       this.doDonate(context, product),
                      //                 ),
                      //               )
                      //               .toList(),
                      //         ),
                      //       )
                      //     : LinearProgressIndicator(),
                      SizedBox(height: PADDING * 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
