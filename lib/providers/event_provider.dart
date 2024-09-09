import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _events = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> get events => _events;

  EventProvider() {
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    User? user = _auth.currentUser;

    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .where('uid', isEqualTo: user.uid)
          .get();

      _events = querySnapshot.docs.map((doc) {
        // Safely handle the 'people' field
        final people = doc['people'];
        List<Map<String, dynamic>> peopleList = [];

        if (people is List) {
          peopleList = people.map((person) {
            // If person is a map, handle it, otherwise treat it as a string
            if (person is Map<String, dynamic>) {
              return {
                'name': person['name'] ?? 'Unknown',
                'price': person['price'] ?? null,
              };
            } else if (person is String) {
              return {
                'name': person,
                'price': null,
              };
            }
            return {'name': 'Unknown', 'price': null}; // Fallback in case of unexpected data
          }).toList();
        }

        return {
          'id': doc.id,
          'name': doc['name'],
          'location': doc['location'],
          'date': doc['date'],
          'time': doc['time'],
          'people': peopleList, // Store the parsed people list
        };
      }).toList();

      notifyListeners();
    }
  }

  Future<void> addEvent(Map<String, dynamic> event) async {
    User? user = _auth.currentUser;

    if (user != null) {
      event['uid'] = user.uid;
      DocumentReference docRef = await _firestore.collection('events').add(event);
      event['id'] = docRef.id;
      _events.add(event);
      notifyListeners();
    }
  }

  Future<void> removeEvent(int index) async {
    String eventId = _events[index]['id'];
    _events.removeAt(index);
    notifyListeners();
    await _firestore.collection('events').doc(eventId).delete();
  }
}
