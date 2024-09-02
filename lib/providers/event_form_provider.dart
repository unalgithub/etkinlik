import 'package:flutter/material.dart';

class EventFormProvider with ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController personController = TextEditingController();

  final List<String> _people = [];

  List<String> get people => _people;

  void addPerson() {
    if (personController.text.isNotEmpty) {
      _people.add(personController.text);
      personController.clear();
      notifyListeners();
    }
  }

  void setDate(String date) {
    dateController.text = date;
    notifyListeners();
  }

  void setTime(String time) {
    timeController.text = time;
    notifyListeners();
  }

  void clearFields() {
    nameController.clear();
    locationController.clear();
    dateController.clear();
    timeController.clear();
    _people.clear();
    notifyListeners();
  }
}
