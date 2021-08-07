import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String imgUrl;
  final String description;
  final double price;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.description,
    required this.price,
    this.isFavourite = false,
  });

  void toggleFavouriteStatus() {
    isFavourite = !isFavourite;
    notifyListeners();
  }
}