import 'package:flutter/foundation.dart';

class EventFormProvider with ChangeNotifier {
  String _name = '';
  String _location = '';
  String _date = '';
  String _time = '';
  final List<String> _people = [];
  
  String get name => _name;
  String get location => _location;
  String get date => _date;
  String get time => _time;
  List<String> get people => _people;
  
  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void setDate(String date) {
    _date = date;
    notifyListeners();
  }

  void setTime(String time) {
    _time = time;
    notifyListeners();
  }

  void addPerson(String person) {
    if (person.isNotEmpty) {
      _people.add(person);
      notifyListeners();
    }
  }

  void removePerson(int index) {
    _people.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _name = '';
    _location = '';
    _date = '';
    _time = '';
    _people.clear();
    notifyListeners();
  }
}
