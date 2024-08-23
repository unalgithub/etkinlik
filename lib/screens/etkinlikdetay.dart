import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EventDetailPage extends StatefulWidget {
  final String eventName;
  final String uniqueId; // Benzersiz ID
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
  double _totalPrice = 0.0;
  List<double> _prices = [];

  @override
  void initState() {
    super.initState();
    _loadData();  // Uygulama açıldığında veri yükleme
  }

  void _addPrice() {
    final price = double.tryParse(_priceController.text);
    if (price != null) {
      setState(() {
        _prices.add(price);
        _totalPrice += price;
        _priceController.clear();
      });
    }
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.eventName}_${widget.uniqueId}_prices', jsonEncode(_prices));
    await prefs.setDouble('${widget.eventName}_${widget.uniqueId}_totalPrice', _totalPrice);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veriler kaydedildi!')),
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context);  // Ana sayfaya dön
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pricesString = prefs.getString('${widget.eventName}_${widget.uniqueId}_prices');
    double? totalPrice = prefs.getDouble('${widget.eventName}_${widget.uniqueId}_totalPrice');

    if (pricesString != null) {
      List<dynamic> pricesList = jsonDecode(pricesString);
      setState(() {
        _prices = pricesList.map((e) => e as double).toList();
        _totalPrice = totalPrice ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fiyat TL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addPrice,
              child: const Text('Ekle'),
            ),
            const SizedBox(height: 16),
            Text(
              'Toplam Fiyat: $_totalPrice TL',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Kişi Başına Düşen Fiyat: ${(_totalPrice / widget.participants.length).toStringAsFixed(2)} TL',
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
                      '${(_totalPrice / widget.participants.length).toStringAsFixed(2)} TL',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveData,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
