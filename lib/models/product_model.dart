// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productId;
  final String title;
  final String imageUrl;
  final String price;
  final String currency;
  final String productName;
  final String brandName;
  final String description;

  const Product({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.productName,
    required this.brandName,
    required this.description,
  });

  @override
  List<Object?> get props =>
      [productId, title, imageUrl, price, currency, productName, brandName, description];
}
