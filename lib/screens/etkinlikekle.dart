import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // easy_localization paketini ekliyoruz

class AddEventPage extends StatefulWidget {
  final void Function(Map<String, dynamic>) onEventAdded;

  const AddEventPage({super.key, required this.onEventAdded});

  @override
  // ignore: library_private_types_in_public_api
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<String> people = [];
  final TextEditingController _personController = TextEditingController();

  void _addPerson() {
    String person = _personController.text;
    if (person.isNotEmpty) {
      setState(() {
        people.add(person);
        _personController.clear();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
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
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = '$hour:$minute';
      });
    }
  }

  void _submitEvent() {
    final String name = _nameController.text;
    final String location = _locationController.text;
    final String date = _dateController.text;
    final String time = _timeController.text;

    if (name.isNotEmpty && location.isNotEmpty && date.isNotEmpty && time.isNotEmpty) {
      widget.onEventAdded({
        'name': name,
        'location': location,
        'date': date,
        'time': time,
        'people': people,
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _personController.dispose();
    super.dispose();
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
            onPressed: _submitEvent,
            tooltip: 'confirm'.tr(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'event_name'.tr()),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'location'.tr()),
            ),
            TextField(
              controller: _dateController,
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
              controller: _timeController,
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
              controller: _personController,
              decoration: InputDecoration(
                labelText: 'add_people'.tr(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addPerson,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: people.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(people[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
