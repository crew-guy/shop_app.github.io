import 'dart:convert';
import 'package:shop_app/providers/cart.dart';
import "package:provider/provider.dart";
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/widgets/product_item.dart';

class OrderItem {
  final String id;
  final double amount;
  final DateTime time;
  final List<CartItem> products;

  OrderItem({
    required this.id,
    required this.amount,
    required this.time,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;
  final String BASE_URL =
      "https://flutter-shop-app-79b4d-default-rtdb.firebaseio.com";

  List<OrderItem> get orders {
    return [..._orders];
  }

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse('${BASE_URL}/orders/$userId.json?auth=${authToken}');
    List<OrderItem> loadedOrders = [];
    try {
      final response = await http.get(url);
      Map<String, dynamic> ordersFromDb = json.decode(response.body);
      if (ordersFromDb == null) {
        return;
      }
      ordersFromDb.forEach(
        (ordId, ord) {
          loadedOrders.add(
            OrderItem(
              id: ordId,
              amount: ord['amount'],
              time: DateTime.parse(ord['time']),
              products: (ord['products'] as List<dynamic>)
                  .map(
                    (item) => CartItem(
                      id: item['id'],
                      price: item['price'],
                      quantity: item['quantity'],
                      title: item['title'],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      );
      notifyListeners();
    } catch (e) {}
  }

  Future<void> addItem(List<CartItem> cartProducts, double amount) async {
    var url = Uri.parse("${BASE_URL}/orders/$userId.json?auth=${authToken}");
    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': amount,
            'time': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cartItem) => {
                      'price': cartItem.price,
                      'title': cartItem.title,
                      'quantity': cartItem.quantity,
                      'id': cartItem.id
                    })
                .toList()
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: amount,
          time: timestamp,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {}
  }
}
