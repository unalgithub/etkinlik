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

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when the app starts
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pricesString = prefs.getString('${widget.eventName}_${widget.uniqueId}_prices');
    double? totalPrice = prefs.getDouble('${widget.eventName}_${widget.uniqueId}_totalPrice');

    if (pricesString != null) {
      List<dynamic> pricesList = jsonDecode(pricesString);
      // ignore: use_build_context_synchronously
      Provider.of<EventDetailProvider>(context, listen: false).setPrices(
        pricesList.map((e) => e as double).toList(),
        totalPrice ?? 0.0,
      );
    }
  }

  void _addPrice() {
    final price = double.tryParse(_priceController.text);
    if (price != null) {
      Provider.of<EventDetailProvider>(context, listen: false).addPrice(price);
      _priceController.clear();
    }
  }

  void _saveData() async {
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
                  '${'price_per_person'.tr()}: ${(eventProvider.totalPrice / widget.participants.length).toStringAsFixed(2)} TL',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.participants.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(widget.participants[index]),
                        trailing: Text(
                          '${(eventProvider.totalPrice / widget.participants.length).toStringAsFixed(2)} TL',
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
