import 'dart:convert';

import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:instagram_flutter/models/product_model.dart';
import 'package:uuid/uuid.dart';

class BranchRepository {
  Future<BranchResponse> generateLink({
    required BranchUniversalObject buo,
    required BranchLinkProperties lp,
  }) async {
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    return response;
  }

  Future<http.Response> postEvent(Product product, String eventName) async {
    return await http.post(
      Uri.parse('https://api2.branch.io/v2/event/standard'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, dynamic>{
          'branch_key': 'key_live_nqiBhXT7vxpB1C0WpN11ukjfEBi6Pfoi',
          'name': eventName,
          'user_data': <String, dynamic>{
            'os': 'Android',
            'ip': '192.168.1.5',
            'advertising_ids': <String, String>{
              'oaid': 'fed3e0df-086f-467f-a7e7-ccf598295f3d'
            }
          },
          'event_data': <String, dynamic>{
            'transaction_id': const Uuid().v4(),
            'revenue': product.price,
            'currency': product.currency,
          },
          'content_items': [
            <String, dynamic>{
              '\$og_title': product.title,
              '\$og_image_url': product.imageUrl,
              '\$canonical_identifier': 'product/${product.productId}',
              '\$price': product.price,
              '\$product_name': product.productName,
              '\$product_brand': product.brandName,
            }
          ]
        },
      ),
    );
  }
}
