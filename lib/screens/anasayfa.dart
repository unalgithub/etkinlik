import 'package:deneme/screens/etkinlikdetay.dart';
import 'package:deneme/screens/etkinlikekle.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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

class _EventPageState extends State<EventPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> events = [];
  int _bottomNavIndex = 0;

  final iconList = <IconData>[
    Icons.event,
    Icons.add,
    Icons.notifications,
    Icons.settings,
  ];

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;

  @override
  void initState() {
    super.initState();
    _loadAllEvents();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  void _loadAllEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      events =
          prefs.getKeys().where((key) => key.endsWith('_details')).map((key) {
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
      }).toList();
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
      extendBody: true,
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      body: _getBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple, // Change the background color
        foregroundColor: Colors.white, // Change the icon color
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
        child: const Icon(Icons.playlist_add_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.blue : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AutoSizeText(
                  "Page $index",
                  maxLines: 1,
                  style: TextStyle(color: color),
                ),
              )
            ],
          );
        },
        backgroundColor: Colors.white,
        activeIndex: _bottomNavIndex,
        splashColor: Colors.blue,
        notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }

  Widget _getBody() {
    switch (_bottomNavIndex) {
      case 0:
        return _buildEventList();
      case 1:
        // Add other cases for different pages if needed
        return const Center(child: Text("Add Event"));
      default:
        return Center(child: Text("Page $_bottomNavIndex"));
    }
  }

  Widget _buildEventList() {
    return Column(
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
                        uniqueId: '',
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
      ],
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
