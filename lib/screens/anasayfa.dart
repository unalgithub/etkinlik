import 'package:flutter/material.dart';
import 'package:deneme/screens/etkinlikekle.dart'; // AddEventPage'in olduğu dosya
import 'package:deneme/screens/etkinlikdetay.dart'; // EventDetailPage'in olduğu dosya
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EventPage(),
    );
  }
}

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadAllEvents();
  }

  void _loadAllEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Event adlarına göre kaydedilmiş verileri yüklüyoruz
    setState(() {
      events = prefs.getKeys()
          .where((key) => key.endsWith('_details'))
          .map((key) {
            String eventName = key.split('_')[0];
            String? eventJson = prefs.getString(key);
            Map<String, dynamic> event = jsonDecode(eventJson ?? '{}');
            return {
              'name': eventName,
              'location': event['location'] ?? 'Bilinmiyor',
              'date': event['date'] ?? 'Bilinmiyor',
              'time': event['time'] ?? 'Bilinmiyor',
              'people': List<String>.from(event['people'] ?? []),
            };
          })
          .toList();
    });
  }

  void _addEvent(Map<String, dynamic> event) {
    setState(() {
      events.add(event);
    });
    _saveEvent(event);
  }

  void _removeEvent(int index) {
    setState(() {
      String eventName = events[index]['name'];
      events.removeAt(index);
      _deleteEvent(eventName);
    });
  }

  void _saveEvent(Map<String, dynamic> event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventName = event['name'];
    prefs.setString('${eventName}_details', jsonEncode(event));
  }

  void _deleteEvent(String eventName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('${eventName}_details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Ana Sayfa'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final people = event['people'] as List<String>? ?? [];
                return GestureDetector(
                  onLongPress: () {
                    _showDeleteDialog(index);
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                          eventName: event['name'],
                          participants: people,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(event['name'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yer: ${event['location']}'),
                          Text('Tarih: ${event['date']}'),
                          Text('Saat: ${event['time']}'),
                          const SizedBox(height: 10),
                          const Text('Katılımcılar:'),
                          ...people.map((person) => Text(person)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Placeholder for future functionality
                },
                child: const Text("Etkinlikler"),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEventPage(
                onEventAdded: (event) {
                  _addEvent(event);
                },
              ),
            ),
          );
        },
        tooltip: 'Etkinlik ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                _removeEvent(index);
                Navigator.of(context).pop();
              },
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
  }
}
