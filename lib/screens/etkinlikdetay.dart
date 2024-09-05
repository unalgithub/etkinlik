import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deneme/providers/event_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';

class EventDetailPage extends StatefulWidget {
  final String eventName;
  final String uniqueId;
  final List<String> participants;

  const EventDetailPage({
    super.key,
    required this.eventName,
    required this.uniqueId,
    required this.participants,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final TextEditingController _priceController = TextEditingController();
  final Map<String, bool> _selectedParticipants = {};

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when the app starts
    widget.participants.forEach((participant) {
      _selectedParticipants[participant] = false;
    });
  }

void _loadData() async {
  try {
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.uniqueId)
        .get();

    if (eventSnapshot.exists) {
      Map<String, dynamic> data = eventSnapshot.data() as Map<String, dynamic>;
      double? totalPrice = data['totalPrice'];
      Map<String, dynamic> selectedParticipants = data['selectedParticipants'];

      if (totalPrice != null) {
        Provider.of<EventDetailProvider>(context, listen: false).setPrices([], totalPrice);
        setState(() {
          _selectedParticipants.addAll(selectedParticipants.map((key, value) => MapEntry(key, value as bool)));
        });
      }
    }
  } catch (e) {
    print("Error loading data from Firestore: $e");
  }
}

  void _addPrice() {
    final price = double.tryParse(_priceController.text);
    if (price != null) {
      Provider.of<EventDetailProvider>(context, listen: false).addPrice(price);
      _priceController.clear();
    }
  }
  Future<void> _saveDataToFirestore() async {
  try {
    final eventProvider = Provider.of<EventDetailProvider>(context, listen: false);
    CollectionReference events = FirebaseFirestore.instance.collection('events');

    await events.doc(widget.uniqueId).set({
      'totalPrice': eventProvider.totalPrice,
      'selectedParticipants': _selectedParticipants.map((key, value) => MapEntry(key, value)),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('saved'.tr())),
    );

    Navigator.pop(context); // Go back to the main page
  } catch (e) {
    print("Error saving data to Firestore: $e");
  }
}

  void _saveData() async {
    await _saveDataToFirestore();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    final eventProvider = Provider.of<EventDetailProvider>(context, listen: false);
    await prefs.setString('${widget.eventName}_${widget.uniqueId}_prices', jsonEncode(eventProvider.prices));
    await prefs.setDouble('${widget.eventName}_${widget.uniqueId}_totalPrice', eventProvider.totalPrice);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('saved'.tr())),
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context); // Go back to the main page
  }

  double _calculateSelectedTotalPrice() {
    int selectedCount = _selectedParticipants.values.where((isSelected) => isSelected).length;
    if (selectedCount == 0) return 0.0;
    return Provider.of<EventDetailProvider>(context, listen: false).totalPrice / selectedCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<EventDetailProvider>(
          builder: (context, eventProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'price'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addPrice,
                  child: Text('add'.tr()),
                ),
                const SizedBox(height: 16),
                Text(
                  '${'total_price'.tr()}: ${eventProvider.totalPrice} TL',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '${'price_per_person'.tr()}: ${_calculateSelectedTotalPrice().toStringAsFixed(2)} TL',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.participants.length,
                    itemBuilder: (context, index) {
                      final participant = widget.participants[index];
                      return CheckboxListTile(
                        value: _selectedParticipants[participant],
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedParticipants[participant] = value!;
                          });
                        },
                        title: Text(participant),
                        secondary: Text(
                          '${_selectedParticipants[participant]! ? (_calculateSelectedTotalPrice().toStringAsFixed(2)) : '0.00'} TL',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveData,
                  child: Text('save'.tr()),
                ),
              ],  
            );
          },
        ),
      ),
    );
  }
}
