import 'package:deneme/providers/event_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';


class AddEventPage extends StatelessWidget {
  final void Function(Map<String, dynamic>) onEventAdded;

  const AddEventPage({super.key, required this.onEventAdded});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
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
      // ignore: use_build_context_synchronously
      Provider.of<EventFormProvider>(context, listen: false)
          .setTime('$hour:$minute');
    }
  }

  void _submitEvent(BuildContext context) {
  final formProvider = Provider.of<EventFormProvider>(context, listen: false);

  final String name = formProvider.nameController.text;
  final String location = formProvider.locationController.text;
  final String date = formProvider.dateController.text;
  final String time = formProvider.timeController.text;

  if (name.isNotEmpty && location.isNotEmpty && date.isNotEmpty && time.isNotEmpty) {
    onEventAdded({
      'name': name,
      'location': location,
      'date': date,
      'time': time,
      'people': List<String>.from(formProvider.people), // Ensure this is a fresh list copy
    });
    formProvider.clearFields();
    Navigator.of(context).pop();
  }
}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventFormProvider(),
      builder: (context, child) {
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
            child: Consumer<EventFormProvider>(
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: formProvider.people.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(formProvider.people[index]),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
