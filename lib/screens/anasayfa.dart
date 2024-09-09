import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deneme/screens/login_screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:deneme/providers/event_provider.dart';
import 'package:deneme/providers/theme_provider.dart';
import 'package:deneme/screens/etkinlikdetay.dart';
import 'package:deneme/screens/etkinlikekle.dart';
import 'package:easy_localization/easy_localization.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> with TickerProviderStateMixin {
  int _bottomNavIndex = 0;

  final iconList = <IconData>[
    Icons.event,
    Icons.add,
    Icons.notifications,
    Icons.settings,
  ];

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;

  @override
  void initState() {
    super.initState();

   

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _getBody(eventProvider),
              if (_bottomNavIndex == 3)
                Positioned(
                  top: 16,
                  right: 15,
                  child: SafeArea(
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Provider.of<ThemeProvider>(context).isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                          onPressed: () {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toogleTheme();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.language),
                          onPressed: () {
                            _changeLanguage(context);
                          },
                        ),
                        IconButton(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () {
                        _signOutAndRedirect(context); // Çıkış fonksiyonunu çağırıyoruz
                      },
                      tooltip: 'logout'.tr(),
                    ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEventPage(
                    onEventAdded: (event) {
                      eventProvider.addEvent(event);
                    },
                  ),
                ),
              );
            },
            tooltip: 'add_event'.tr(),
            child: const Icon(Icons.playlist_add_outlined),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              final color = isActive ? Colors.purple : Colors.grey;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconList[index],
                    size: 24,
                    color: color,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AutoSizeText(
                      index == 0
                          ? "events".tr()
                          : index == 3
                              ? "settings".tr()
                              : "page".tr(args: [index.toString()]),
                      maxLines: 1,
                      style: TextStyle(color: color),
                    ),
                  )
                ],
              );
            },
            backgroundColor: Colors.white,
            activeIndex: _bottomNavIndex,
            splashColor: Colors.blue,
            notchAndCornersAnimation: borderRadiusAnimation,
            splashSpeedInMilliseconds: 300,
            notchSmoothness: NotchSmoothness.defaultEdge,
            gapLocation: GapLocation.center,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            onTap: (index) => setState(() => _bottomNavIndex = index),
          ),
        );
      },
    );
  }
  

  void _changeLanguage(BuildContext context) {
    final currentLocale = context.locale;
    if (kDebugMode) {
      print("Current Locale: $currentLocale");
    }

    final newLocale = currentLocale == const Locale('tr', 'TR')
        ? const Locale('en', 'US')
        : const Locale('tr', 'TR');
    
    context.setLocale(newLocale);
    if (kDebugMode) {
      print("New Locale: $newLocale");
    }
  }
    Future<void> _signOutAndRedirect(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(), // Giriş ekranına yönlendirme
      ),
    );
  }

Widget _getBody(EventProvider eventProvider) {
  switch (_bottomNavIndex) {
    case 0:
      return _buildEventList(eventProvider);
    case 1:
      return Center(child: Text("Sayfa 1".tr()));
    case 3:
      return _buildSettingsPage();
    default:
      return Center(child: Text("page".tr(args: [_bottomNavIndex.toString()])));
  }
}
Widget _buildSettingsPage() {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return Center(child: Text("Kullanıcı oturum açmamış."));
  }

  // Kullanıcının Firestore'daki belgelerini almak
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        print("Hata: ${snapshot.error}"); // Hata mesajını konsola yazdır
        return Center(child: Text("Veri alınırken hata oluştu."));
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        print("Kullanıcı ID: ${currentUser.uid}"); // Kullanıcı ID'sini konsola yazdır
        return Center(child: Text("Kullanıcı bilgileri bulunamadı."));
      }

      // Veritabanından kullanıcı adını al
      String userName = snapshot.data!['name'] ?? "Kullanıcı Adı"; // Varsayılan metin
      String userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?'; // Boşsa '?' göster

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple,
              child: Text(
                userInitial,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(fontSize: 20),
            ),
            // Diğer ayarlar, butonlar vb. burada
          ],
        ),
      );
    },
  );
}

Widget _buildEventList(EventProvider eventProvider) {
  return Column(
    children: [
      Expanded(
        child: ListView.builder(
          itemCount: eventProvider.events.length,
          itemBuilder: (context, index) {
            final event = eventProvider.events[index];

            // Casting participants to List<String>
            final people = (event['people'] as List<dynamic>)
                .map((person) => person is Map<String, dynamic> ? person['name'].toString() : person.toString())
                .toList();

            return InkWell(
              onLongPress: () {
                _showDeleteDialog(index, eventProvider);
              },
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      eventName: event['name'],
                      participants: people,
                      uniqueId: '', // Ensure you pass the correct uniqueId here
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(event['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${"location".tr()}: ${event['location']}'),
                      Text('${"date".tr()}: ${event['date']}'),
                      Text('${"time".tr()}: ${event['time']}'),
                      const SizedBox(height: 10),
                      Text('participants'.tr()),
                      ...people.map((person) => Text(person)), // Show only the participant names
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}


  void _showDeleteDialog(int index, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("delete_confirmation".tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel".tr()),
            ),
            TextButton(
              onPressed: () {
                eventProvider.removeEvent(index);
                Navigator.of(context).pop();
              },
              child: Text("delete".tr()),
            ),
          ],
        );
      },
    );
  }
}
