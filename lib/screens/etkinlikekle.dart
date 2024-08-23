import 'package:flutter/material.dart'; // Flutter'ın material tasarım bileşenlerini kullanmak için

class AddEventPage extends StatefulWidget {
  final void Function(Map<String, dynamic>) onEventAdded; // Etkinlik eklendiğinde çağrılacak fonksiyon

  const AddEventPage({super.key, required this.onEventAdded}); // Constructor, onEventAdded fonksiyonunu alır

  @override
  // ignore: library_private_types_in_public_api
  _AddEventPageState createState() => _AddEventPageState(); // State oluşturulur
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _nameController = TextEditingController(); // Etkinlik ismi için controller
  final TextEditingController _locationController = TextEditingController(); // Yer için controller
  final TextEditingController _dateController = TextEditingController(); // Tarih için controller
  final TextEditingController _timeController = TextEditingController(); // Saat için controller
  List<String> people = []; // Kişileri saklamak için liste
  final TextEditingController _personController = TextEditingController(); // Kişi eklemek için controller

  void _addPerson() {
    // Kişi ekleme işlevi
    String person = _personController.text; // TextField'dan kişiyi al
    if (person.isNotEmpty) { // Kişi boş değilse
      setState(() {
        people.add(person); // Kişiyi listeye ekle
        _personController.clear(); // TextField'i temizle
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Tarih seçimi işlevi
    final DateTime? picked = await showDatePicker(
      context: context, // Dialog'un gösterileceği context
      initialDate: DateTime.now(), // Varsayılan olarak bugünkü tarih
      firstDate: DateTime.now(), // Seçilebilecek en erken tarih
      lastDate: DateTime(2100), // Seçilebilecek en geç tarih
    );
    if (picked != null) {
      // Eğer bir tarih seçildiyse
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0]; // Seçilen tarihi TextField'a yaz
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
  // Saat seçimi işlevi
  final TimeOfDay? picked = await showTimePicker(
    context: context, // Dialog'un gösterileceği context
    initialTime: TimeOfDay.now(), // Varsayılan olarak mevcut saat
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // 24 saat formatını etkinleştir
        child: child!,
      );
    },
  );
    if (picked != null) {
  // Eğer bir saat seçildiyse
  setState(() {
    // Seçilen saati 24 saat formatında TextField'a yaz
    final hour = picked.hour.toString().padLeft(2, '0'); // Saati iki basamaklı olacak şekilde formatla
    final minute = picked.minute.toString().padLeft(2, '0'); // Dakikayı iki basamaklı olacak şekilde formatla
    _timeController.text = '$hour:$minute'; // Saati ve dakikayı birleştir
  });
}
  }

  void _submitEvent() {
    // Etkinlik gönderme işlevi
    final String name = _nameController.text; // Etkinlik ismini al
    final String location = _locationController.text; // Yeri al
    final String date = _dateController.text; // Tarihi al
    final String time = _timeController.text; // Saati al

    if (name.isNotEmpty && location.isNotEmpty && date.isNotEmpty && time.isNotEmpty) {
      // Tüm alanlar doluysa
      widget.onEventAdded({
        'name': name,
        'location': location,
        'date': date,
        'time': time,
        'people': people, // Kişileri etkinlik bilgileriyle birlikte gönder
      });
      Navigator.of(context).pop(); // Sayfayı kapat
    }
  }

  @override
  void dispose() {
    // Kullanıcı arayüzü bileşenleri kapatılırken çağrılır
    _nameController.dispose(); // _nameController'ı kapat
    _locationController.dispose(); // _locationController'ı kapat
    _dateController.dispose(); // _dateController'ı kapat
    _timeController.dispose(); // _timeController'ı kapat
    _personController.dispose(); // _personController'ı kapat
    super.dispose(); // Üst sınıfın dispose metodunu çağır
  }

  @override
  Widget build(BuildContext context) {
    // Uygulamanın görünümünü oluşturan build metodu
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Geri butonu ikonu
          onPressed: () {
            Navigator.of(context).pop(); // Geri butonuna tıklanınca sayfayı kapat
          },
        ),
        title: const Text('Etkinlik Ekle'), // Sayfanın başlığı
        actions: [
          IconButton(
            icon: const Icon(Icons.check), // Onay butonu ikonu
            onPressed: _submitEvent, // Onay butonuna tıklanınca etkinliği gönder
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Sayfa kenar boşlukları
        child: Column(
          children: [
            TextField(
              controller: _nameController, // Etkinlik ismi için controller
              decoration: const InputDecoration(labelText: 'Etkinlik ismi'), // TextField'in etiketi
            ),
            TextField(
              controller: _locationController, // Yeri için controller
              decoration: const InputDecoration(labelText: 'Yeri'), // TextField'in etiketi
            ),
            TextField(
              controller: _dateController, // Tarih için controller
              decoration: InputDecoration(
                labelText: 'Tarihi', // TextField'in etiketi
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today), // Takvim ikonu
                  onPressed: () => _selectDate(context), // Tarih seçimi için buton
                ),
              ),
              readOnly: true, // Sadece tıklama ile seçim yapılabilir
            ),
            TextField(
              controller: _timeController, // Saat için controller
              decoration: InputDecoration(
                labelText: 'Saati', // TextField'in etiketi
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time), // Saat ikonu
                  onPressed: () => _selectTime(context), // Saat seçimi için buton
                ),
              ),
              readOnly: true, // Sadece tıklama ile seçim yapılabilir
            ),
            TextField(
              controller: _personController, // Kişi eklemek için controller
              decoration: InputDecoration(
                labelText: 'Kişilere ekle', // TextField'in etiketi
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline), // Ekleme butonu ikonu
                  onPressed: _addPerson, // Ekleme butonuna tıklanınca kişiyi ekle
                ),
              ),
            ),
            const SizedBox(height: 20), // Görsel boşluk
            Expanded(
              child: ListView.builder(
                itemCount: people.length, // Kişi sayısına göre liste öğesi sayısı
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(people[index]), // Kişi ismini göster
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
