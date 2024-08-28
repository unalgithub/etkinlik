import 'package:deneme/providers/event_add_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddEventPage extends StatelessWidget {
  final void Function(Map<String, dynamic>) onEventAdded;

  const AddEventPage({super.key, required this.onEventAdded});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Etkinlik Ekle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (provider.name.isNotEmpty && provider.location.isNotEmpty &&
                  provider.date.isNotEmpty && provider.time.isNotEmpty) {
                onEventAdded({
                  'name': provider.name,
                  'location': provider.location,
                  'date': provider.date,
                  'time': provider.time,
                  'people': provider.people,
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) => provider.setName(value),
              decoration: const InputDecoration(labelText: 'Etkinlik ismi'),
              controller: TextEditingController(text: provider.name),
            ),
            TextField(
              onChanged: (value) => provider.setLocation(value),
              decoration: const InputDecoration(labelText: 'Yeri'),
              controller: TextEditingController(text: provider.location),
            ),
            TextField(
              onChanged: (value) => provider.setDate(value),
              decoration: InputDecoration(
                labelText: 'Tarihi',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
              controller: TextEditingController(text: provider.date),
            ),
            TextField(
              onChanged: (value) => provider.setTime(value),
              decoration: InputDecoration(
                labelText: 'Saati',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
              ),
              readOnly: true,
              controller: TextEditingController(text: provider.time),
            ),
            TextField(
              onChanged: (value) => provider.addPerson(value),
              decoration: InputDecoration(
                labelText: 'Kişilere ekle',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    if (provider.people.isNotEmpty) {
                      provider.addPerson(provider.people.last);
                    }
                  },
                ),
              ),
              controller: TextEditingController(text: provider.people.isEmpty ? '' : provider.people.last),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: provider.people.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(provider.people[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => provider.removePerson(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = Provider.of<EventFormProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      provider.setDate("${picked.toLocal()}".split(' ')[0]);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final provider = Provider.of<EventFormProvider>(context, listen: false);
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
      provider.setTime('$hour:$minute');
    }
  }
}
