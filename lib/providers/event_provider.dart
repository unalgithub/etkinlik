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
        return {
          'id': doc.id, // documentId ekleyin
          'name': doc['name'],
          'location': doc['location'],
          'date': doc['date'],
          'time': doc['time'],
          'people': List<String>.from(doc['people']),
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
      event['id'] = docRef.id; // documentId'yi etkinliğe ekleyin
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
