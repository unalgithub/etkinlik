import 'package:flutter/material.dart';

class EventDetailProvider with ChangeNotifier {
  Map<String, bool> _selectedParticipants = {};
  Map<String, double> _participantPrices = {};
  double _currentPrice = 0.0;
  double _totalPrice = 0.0;

  Map<String, bool> get selectedParticipants => _selectedParticipants;
  Map<String, double> get participantPrices => _participantPrices;
  double get currentPrice => _currentPrice;
  double get totalPrice => _totalPrice;

  void initializeParticipants(List<String> participants) {
    _selectedParticipants = {for (var p in participants) p: false};
    _participantPrices = {for (var p in participants) p: 0.0};
  }

  void addPrice(double price) {
    _currentPrice = price;
    _totalPrice += price;
    notifyListeners();
  }

  double calculateCurrentPricePerPerson() {
    int selectedCount = _selectedParticipants.values.where((isSelected) => isSelected).length;
    if (selectedCount == 0) return 0.0;
    return _currentPrice / selectedCount;
  }

  void updateSelectedParticipant(String participant, bool isSelected) {
    _selectedParticipants[participant] = isSelected;
    notifyListeners();
  }

  void confirmAndSavePrices() {
    _selectedParticipants.forEach((participant, isSelected) {
      if (isSelected) {
        double pricePerPerson = calculateCurrentPricePerPerson();
        _participantPrices[participant] = (_participantPrices[participant] ?? 0.0) + pricePerPerson;
      }
    });

    _currentPrice = 0.0;
    _selectedParticipants.updateAll((key, value) => false);
    notifyListeners();
  }

  void loadPrices(double totalPrice, Map<String, double> participantPrices) {
    _totalPrice = totalPrice;
    _participantPrices = participantPrices;
    notifyListeners();
  }
}
