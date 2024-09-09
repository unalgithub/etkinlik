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
  String _selectedExpenseType = '';

  final List<String> _expenseTypes = ['food'.tr(), 'transport'.tr(), 'accomodation'.tr(), 'other'.tr()];

  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventDetailProvider>(context, listen: false);
    eventProvider.initializeParticipants(widget.participants);
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedTotalPrice = prefs.getDouble('${widget.eventName}_${widget.uniqueId}_totalPrice');
    if (savedTotalPrice != null) {
      String? savedParticipantPrices = prefs.getString('${widget.eventName}_${widget.uniqueId}_participantPrices');
      if (savedParticipantPrices != null) {
        Map<String, dynamic> loadedPrices = jsonDecode(savedParticipantPrices);
        Map<String, double> participantPrices = {};
        loadedPrices.forEach((key, value) {
          participantPrices[key] = value;
        });

        Provider.of<EventDetailProvider>(context, listen: false).loadPrices(savedTotalPrice, participantPrices);
      }
    }
  }

  void _addPrice(EventDetailProvider eventProvider) {
    final price = double.tryParse(_priceController.text);
    if (price != null) {
      eventProvider.addPrice(price);
      _priceController.clear();
    }
  }

  void _confirmAndSavePrices(EventDetailProvider eventProvider) {
    eventProvider.confirmAndSavePrices();
  }

  void _saveData(EventDetailProvider eventProvider) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${widget.eventName}_${widget.uniqueId}_totalPrice', eventProvider.totalPrice);
    await prefs.setString('${widget.eventName}_${widget.uniqueId}_participantPrices', jsonEncode(eventProvider.participantPrices));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('saved'.tr())),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                    onPressed: () => _addPrice(eventProvider),
                    child: Text('add'.tr()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${'total_price'.tr()}: ${eventProvider.totalPrice} TL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${'current_price'.tr()}: ${eventProvider.currentPrice} TL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${'price_per_person'.tr()}: ${eventProvider.calculateCurrentPricePerPerson().toStringAsFixed(2)} TL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.participants.length,
                    itemBuilder: (context, index) {
                      final participant = widget.participants[index];
                      return CheckboxListTile(
                        value: eventProvider.selectedParticipants[participant],
                        onChanged: (bool? value) {
                          eventProvider.updateSelectedParticipant(participant, value!);
                        },
                        title: Text(participant),
                        secondary: Text(
                          '${eventProvider.participantPrices[participant] != 0 ? eventProvider.participantPrices[participant]!.toStringAsFixed(2) : '0.00'} TL',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _confirmAndSavePrices(eventProvider), // Onayla ve fiyatları kaydet
                    child: Text('confirm'.tr()),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _saveData(eventProvider), // Kaydet
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
  bool get wantKeepAlive => true;
}
