class Event {
  final String name;
  final String location;
  final String date;
  final String time;
  final List<String> people;

  Event({
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.people,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      people: List<String>.from(json['people'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'date': date,
      'time': time,
      'people': people,
    };
  }
}
