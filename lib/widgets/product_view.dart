import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/product_model.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key, required this.product, required this.onShare});

  final Product product;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl: product.imageUrl,
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height / 2.25,
          width: double.infinity,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.bookmark_outline,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onShare,
              icon: const Icon(
                Icons.share,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${product.brandName} ${product.productName}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
              Text(
                '${product.currency} - ${product.price} /-',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color.fromARGB(255, 1, 137, 5),
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: product.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                    TextSpan(),
                  ],
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
