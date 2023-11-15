// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'package:instagram_flutter/models/product_model.dart';
import 'package:instagram_flutter/repositories/branch/branch_repositpry.dart';
import 'package:instagram_flutter/widgets/product_view.dart';

class ProductScreenArgs {
  final Product product;
  const ProductScreenArgs({
    required this.product,
  });
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.product});

  final Product product;

  static const String routeName = '/product_screen';

  static Route getRoute({required ProductScreenArgs args}) {
    return MaterialPageRoute(
        builder: (_) => ProductScreen(
              product: args.product,
            ),
        settings: const RouteSettings(name: routeName));
  }

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: SingleChildScrollView(
          child: ProductView(
            product: widget.product,
            onShare: () {
              shareProduct(widget.product);
            },
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  disabledBackgroundColor: Colors.blue[100],
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  final response = await context
                      .read<BranchRepository>()
                      .postEvent(widget.product, 'ADD_TO_CART');

                  if (response.statusCode == 200) {
                    print('Add to cart event success');
                    showSuccessSnackBar(
                        message: 'Add to cart event sent successfully.');
                  } else {
                    print('Add to cart: ${response.statusCode}');
                    showErrorSnackBar(
                        message:
                            'Add to cart event failed: Error ${response.statusCode}');
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_rounded),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Add to cart')
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    disabledBackgroundColor: Colors.blue[100],
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                onPressed: () async {
                  final response = await context
                      .read<BranchRepository>()
                      .postEvent(widget.product, 'PURCHASE');

                  if (response.statusCode == 200) {
                    print('Purchase event success');
                    showSuccessSnackBar(
                        message: 'Purchase event sent successfully');
                  } else {
                    print('Purchase event failed: ${response.statusCode}');
                    showErrorSnackBar(
                        message:
                            'Purchase event generation failed: Error - ${response.statusCode}');
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_money),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Buy now')
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void shareProduct(Product product) async {
    print(
        'Canonical data => identifier: product/${product.productId} , url: ${product.imageUrl} , title: ${product.title} , productId: ${product.productId}');

    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'product/${product.productId}',
      canonicalUrl: product.imageUrl,
      title: product.title,
      contentDescription: product.description,
      imageUrl: product.imageUrl,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('productId', product.productId)
        ..addCustomMetadata('productName', product.productName)
        ..addCustomMetadata('brandName', product.brandName)
        ..addCustomMetadata('\$amount', product.price)
        ..addCustomMetadata('\$currency', product.currency)
        ..addCustomMetadata('contentType', 'product'),
      publiclyIndex: true,
      locallyIndex: true,
      expirationDateInMilliSec:
          DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
    );

    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'WhatsApp',
        feature: 'marketing',
        tags: ['Camping', 'Equipment'],
        campaign: 'Decathlon Promo');

    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText: 'Checkout this product from ${product.brandName}.',
        androidMessageTitle: 'Share via',
        androidSharingTitle: 'Share Product');

    if (response.success) {
      print('Link shared successfully.');
      showSuccessSnackBar(message: 'Link shared successfully');
      BranchEvent event = BranchEvent.customEvent('Sharing product');
      FlutterBranchSdk.trackContentWithoutBuo(branchEvent: event);
    } else {
      print(
          'Failed to generate link: ${response.errorCode} - ${response.errorMessage}');
      showErrorSnackBar(
          message:
              'Failed to generate link: Error ${response.errorCode} - ${response.errorMessage}');
    }
  }

  void showSuccessSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(30.0),
        backgroundColor: Colors.green,
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  void showErrorSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(30.0),
        backgroundColor: Colors.red,
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }
}
