import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EventProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _events = [];

  List<Map<String, dynamic>> get events => _events;

  EventProvider() {
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _events = prefs.getKeys().where((key) => key.endsWith('_details')).map((key) {
      String eventName = key.split('_')[0];
      String? eventJson = prefs.getString(key);
      try {
        Map<String, dynamic> event = jsonDecode(eventJson ?? '{}');
        return {
          'name': eventName,
          'location': event['location'] ?? 'Bilinmiyor',
          'date': event['date'] ?? 'Bilinmiyor',
          'time': event['time'] ?? 'Bilinmiyor',
          'people': List<String>.from(event['people'] ?? []),
        };
      } catch (e) {
        // Hata durumunda varsayılan değer döndür
        return {
          'name': eventName,
          'location': 'Bilinmiyor',
          'date': 'Bilinmiyor',
          'time': 'Bilinmiyor',
          'people': [],
        };
      }
    }).toList();
    notifyListeners();
  }

  Future<void> addEvent(Map<String, dynamic> event) async {
    _events.add(event);
    notifyListeners();
    await _saveEvent(event);
  }

  Future<void> removeEvent(int index) async {
    String eventName = _events[index]['name'];
    _events.removeAt(index);
    notifyListeners();
    await _deleteEvent(eventName);
  }

  Future<void> _saveEvent(Map<String, dynamic> event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventName = event['name'];
    await prefs.setString('${eventName}_details', jsonEncode(event));
  }

  Future<void> _deleteEvent(String eventName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('${eventName}_details');
  }
}