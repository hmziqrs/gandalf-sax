import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPProvider extends ChangeNotifier {
  bool loading = true;
  List<ProductDetails> products;

  IAPProvider() {
    this.initAsync();
  }

  initAsync() async {
    const Set<String> rawIds = {'donate_1', 'donate_2', 'donate_3'};
    await InAppPurchaseConnection.instance.isAvailable();
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(rawIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    this.products = response.productDetails;
    this.loading = false;
    this.notifyListeners();
  }
}
