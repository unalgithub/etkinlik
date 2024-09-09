import 'package:flutter/material.dart';

class EventDetailProvider extends ChangeNotifier {
  double _totalPrice = 0.0;
  List<double> _prices = [];

  double get totalPrice => _totalPrice;
  List<double> get prices => _prices;

  // Adds a price and updates the total
  void addPrice(double price) {
    _prices.add(price);
    _totalPrice += price;
    notifyListeners();
  }

  // Sets prices and total price
  void setPrices(List<double> prices, double totalPrice) {
    _prices = prices;
    _totalPrice = totalPrice;
    notifyListeners();
  }

  // Removes a price by index and updates the total
  void removePrice(int index) {
    if (index >= 0 && index < _prices.length) {
      _totalPrice -= _prices[index];
      _prices.removeAt(index);
      notifyListeners();
    }
  }

  // Method to set the total price directly
  void setTotalPrice(double totalPrice) {
    _totalPrice = totalPrice;
    notifyListeners();
  }
}
