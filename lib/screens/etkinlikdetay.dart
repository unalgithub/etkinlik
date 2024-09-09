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
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final TextEditingController _priceController = TextEditingController();
  final Map<String, bool> _selectedParticipants = {};
  final Map<String, double> _participantPrices = {}; // Fiyatları tutmak için map
  double _currentPrice = 0.0; // Girilen şu anki fiyat
  double _totalPrice = 0.0; // Toplam fiyat
  String _selectedExpenseType = ''; // Seçilen harcama tipi

  // Harcama tipleri listesi
  final List<String> _expenseTypes = ['food'.tr(), 'transport'.tr(), 'accomodation'.tr(), 'other'.tr()];

  @override
  void initState() {
    super.initState();
    _loadData(); // Uygulama başlarken verileri yükleyelim
    widget.participants.forEach((participant) {
      _selectedParticipants[participant] = false;
      _participantPrices[participant] = 0.0; // Başlangıçta tüm kişilerin fiyatı 0
    });
  }

  // SharedPreferences'den verileri yükleyelim
  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Toplam fiyatı yükle
    double? savedTotalPrice = prefs.getDouble('${widget.eventName}_${widget.uniqueId}_totalPrice');
    if (savedTotalPrice != null) {
      setState(() {
        _totalPrice = savedTotalPrice; // Kaydedilen toplam fiyatı yükle
      });
    }
    
    // Katılımcı fiyatlarını yükle
    String? savedParticipantPrices = prefs.getString('${widget.eventName}_${widget.uniqueId}_participantPrices');
    if (savedParticipantPrices != null) {
      Map<String, dynamic> loadedPrices = jsonDecode(savedParticipantPrices);
      loadedPrices.forEach((key, value) {
        setState(() {
          _participantPrices[key] = value;
        });
      });
    }
  }

  // Fiyat eklerken toplam fiyatı da güncelleyelim
  void _addPrice() {
    final price = double.tryParse(_priceController.text);
    if (price != null) {
      setState(() {
        _currentPrice = price; // Şu anki fiyatı güncelle 
        _totalPrice += _currentPrice; // Toplam fiyatı güncelle
      });
      _priceController.clear();
    }
  }

  double _calculateCurrentPricePerPerson() {
    int selectedCount = _selectedParticipants.values.where((isSelected) => isSelected).length;
    if (selectedCount == 0) return 0.0;
    return _currentPrice / selectedCount; // Sadece şu anki fiyatı böl
  }

  // Fiyatları kaydetme işlemi, _totalPrice'ı da kaydedelim
  void _confirmAndSavePrices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, double> participantPrices = {};

    _selectedParticipants.forEach((participant, isSelected) {
      if (isSelected) {
        double pricePerPerson = _calculateCurrentPricePerPerson();
        participantPrices[participant] = pricePerPerson;
        _participantPrices[participant] = (_participantPrices[participant] ?? 0.0) + pricePerPerson;
      }
    });

    // Checkboxları kaldır
    setState(() {
      _selectedParticipants.updateAll((key, value) => false);
      _currentPrice = 0.0; // Şu anki fiyatı sıfırla
    });

    await prefs.setString('${widget.eventName}_${widget.uniqueId}_participantPrices', jsonEncode(_participantPrices));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('prices_saved'.tr())),
    );
  }

  // Fiyatları ve toplam fiyatı SharedPreferences'a kaydet
  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Toplam fiyatı kaydet
    await prefs.setDouble('${widget.eventName}_${widget.uniqueId}_totalPrice', _totalPrice);
    
    // Katılımcı fiyatlarını kaydet
    await prefs.setString('${widget.eventName}_${widget.uniqueId}_participantPrices', jsonEncode(_participantPrices));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('saved'.tr())),
    );

    Navigator.pop(context); // Ana sayfaya dön
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
                // Harcama Tipi Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedExpenseType.isNotEmpty ? _selectedExpenseType : null,
                  decoration: InputDecoration(
                    labelText: 'expense_type'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  items: _expenseTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExpenseType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Fiyat girişi için TextField
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'current_price'.tr(), // Şu anki fiyat
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
                  '${'total_price'.tr()}: $_totalPrice TL', // Toplam fiyat
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${'current_price'.tr()}: $_currentPrice TL', // Şu anki fiyat
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '${'price_per_person'.tr()}: ${_calculateCurrentPricePerPerson().toStringAsFixed(2)} TL', // Şu anki fiyat kişilere bölündü
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Expanded ListView to make participants scrollable
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
                          '${_participantPrices[participant] != 0 ? _participantPrices[participant]!.toStringAsFixed(2) : '0.00'} TL', // Katılımcı fiyatı
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _confirmAndSavePrices, // Onayla ve fiyatları kaydet
                  child: Text('confirm'.tr()),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saveData, // Kaydet
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
