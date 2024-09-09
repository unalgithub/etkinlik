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

class _EventDetailPageState extends State<EventDetailPage> with AutomaticKeepAliveClientMixin<EventDetailPage> {
  final TextEditingController _priceController = TextEditingController();
  final Map<String, bool> _selectedParticipants = {};
  final Map<String, double> _participantPrices = {};
  double _currentPrice = 0.0;
  double _totalPrice = 0.0;
  String _selectedExpenseType = '';

  final List<String> _expenseTypes = ['food'.tr(), 'transport'.tr(), 'accomodation'.tr(), 'other'.tr()];

  @override
  void initState() {
    super.initState();
    _loadData();
    widget.participants.forEach((participant) {
      _selectedParticipants[participant] = false;
      _participantPrices[participant] = 0.0;
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedTotalPrice = prefs.getDouble('${widget.eventName}_${widget.uniqueId}_totalPrice');
    if (savedTotalPrice != null) {
      _totalPrice = savedTotalPrice;
    }

    String? savedParticipantPrices = prefs.getString('${widget.eventName}_${widget.uniqueId}_participantPrices');
    if (savedParticipantPrices != null) {
      Map<String, dynamic> loadedPrices = jsonDecode(savedParticipantPrices);
      loadedPrices.forEach((key, value) {
        _participantPrices[key] = value;
      });
    }
  }

  void _addPrice() {
    final price = double.tryParse(_priceController.text);
    if (price != null) {
      setState(() {
        _currentPrice = price;
        _totalPrice += _currentPrice;
      });
      _priceController.clear();
    }
  }

  double _calculateCurrentPricePerPerson() {
    int selectedCount = _selectedParticipants.values.where((isSelected) => isSelected).length;
    if (selectedCount == 0) return 0.0;
    return _currentPrice / selectedCount;
  }

  void _confirmAndSavePrices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _selectedParticipants.forEach((participant, isSelected) {
      if (isSelected) {
        double pricePerPerson = _calculateCurrentPricePerPerson();
        _participantPrices[participant] = (_participantPrices[participant] ?? 0.0) + pricePerPerson;
      }
    });

    setState(() {
      _selectedParticipants.updateAll((key, value) => false);
      _currentPrice = 0.0;
    });

    await prefs.setString('${widget.eventName}_${widget.uniqueId}_participantPrices', jsonEncode(_participantPrices));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('prices_saved'.tr())),
    );
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${widget.eventName}_${widget.uniqueId}_totalPrice', _totalPrice);
    await prefs.setString('${widget.eventName}_${widget.uniqueId}_participantPrices', jsonEncode(_participantPrices));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('saved'.tr())),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: unused_local_variable
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // İçerikleri kaydırılabilir hale getiriyoruz
          child: Consumer<EventDetailProvider>(
            builder: (context, eventProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'current_price'.tr(),
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
                    '${'total_price'.tr()}: $_totalPrice TL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${'current_price'.tr()}: $_currentPrice TL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${'price_per_person'.tr()}: ${_calculateCurrentPricePerPerson().toStringAsFixed(2)} TL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true, // ListView'ı sıkıştırarak kullanıyoruz
                    physics: NeverScrollableScrollPhysics(), // İç içe kaydırmayı engelliyoruz
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
                          '${_participantPrices[participant] != 0 ? _participantPrices[participant]!.toStringAsFixed(2) : '0.00'} TL',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _confirmAndSavePrices,
                    child: Text('confirm'.tr()),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveData,
                    child: Text('save'.tr()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Durumun korunmasını sağlar
}
