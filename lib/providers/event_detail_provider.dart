import 'package:flutter/material.dart';

class EventDetailProvider extends ChangeNotifier {
  double _totalPrice = 0.0;
  List<double> _prices = [];

  double get totalPrice => _totalPrice;
  List<double> get prices => _prices;

  void addPrice(double price) {
    _prices.add(price);
    _totalPrice += price;
    notifyListeners();
  }

  void setPrices(List<double> prices, double totalPrice) {
    _prices = prices;
    _totalPrice = totalPrice;
    notifyListeners();
  }
  void removePrice(int index) {
    if (index >= 0 && index < _prices.length) {
      _totalPrice -= _prices[index];
      _prices.removeAt(index);
      notifyListeners();
    }

}
}
