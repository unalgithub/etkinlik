import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deneme/providers/event_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
final String uid = user!.uid; // Kullanıcının benzersiz ID'si

class AddEventPage extends StatefulWidget {
  final void Function(Map<String, dynamic>) onEventAdded;

  const AddEventPage({super.key, required this.onEventAdded});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      Provider.of<EventFormProvider>(context, listen: false)
          .setDate("${picked.toLocal()}".split(' ')[0]);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      Provider.of<EventFormProvider>(context, listen: false)
          .setTime('$hour:$minute');
    }
  }

  void _submitEvent(BuildContext context) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final formProvider = Provider.of<EventFormProvider>(context, listen: false);

    final String name = formProvider.nameController.text;
    final String location = formProvider.locationController.text;
    final String date = formProvider.dateController.text;
    final String time = formProvider.timeController.text;
    final List<String> people = List<String>.from(formProvider.people);

    if (name.isNotEmpty &&
        location.isNotEmpty &&
        date.isNotEmpty &&
        time.isNotEmpty) {
      // Her kişiye başlangıçta price null atanıyor
      final List<Map<String, dynamic>> peopleWithPrices = people.map((person) {
        return {
          'name': person,
          'price': '' // Price başlangıçta boş/null
        };
      }).toList();

      // Firestore'a veri ekleme
      FirebaseFirestore.instance.collection('events').add({
        'uid': uid, // Kullanıcının ID'si ekleniyor
        'name': name,
        'location': location,
        'date': date,
        'time': time,
        'people': peopleWithPrices, // Kişiler ve başlangıçta boş fiyatlar ekleniyor
      }).then((value) {
        widget.onEventAdded({
          'name': name,
          'location': location,
          'date': date,
          'time': time,
          'people': peopleWithPrices,
        });
        formProvider.clearFields();
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinlik eklenemedi: $error')),
        );
      }).whenComplete(() {
        setState(() {
          _isSubmitting = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'back'.tr(),
        ),
        title: Text('add_event'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _submitEvent(context),
            tooltip: 'confirm'.tr(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Ekran taşmasını önlemek için kaydırılabilir hale getirdik
          child: Column(
            children: [
              Consumer<EventFormProvider>(
                builder: (context, formProvider, child) {
                  return Column(
                    children: [
                      TextField(
                        controller: formProvider.nameController,
                        decoration: InputDecoration(labelText: 'event_name'.tr()),
                      ),
                      TextField(
                        controller: formProvider.locationController,
                        decoration: InputDecoration(labelText: 'location'.tr()),
                      ),
                      TextField(
                        controller: formProvider.dateController,
                        decoration: InputDecoration(
                          labelText: 'date'.tr(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        readOnly: true,
                      ),
                      TextField(
                        controller: formProvider.timeController,
                        decoration: InputDecoration(
                          labelText: 'time'.tr(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(context),
                          ),
                        ),
                        readOnly: true,
                      ),
                      TextField(
                        controller: formProvider.personController,
                        decoration: InputDecoration(
                          labelText: 'add_people'.tr(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: formProvider.addPerson,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
              Consumer<EventFormProvider>(
                builder: (context, formProvider, child) {
                  return SizedBox(
                    height: 200, // ListView'in boyutunu sınırlıyoruz
                    child: ListView.builder(
                      itemCount: formProvider.people.length,
                      itemBuilder: (context, index) {
                        final person = formProvider.people[index];
                        return ListTile(
                          title: Text(person),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
