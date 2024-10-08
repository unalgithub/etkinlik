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

    // FloatingActionButton animasyonunu başlatıyoruz
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Border animasyonunu başlatıyoruz
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

    // fabAnimation ve borderRadiusAnimation tanımlıyoruz
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
  void dispose() {
    _fabAnimationController.dispose();
    _borderRadiusAnimationController.dispose();
    super.dispose();
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
    // ignore: use_build_context_synchronously
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

  Widget _buildEventList(EventProvider eventProvider) {
    if (eventProvider.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "no_events_available".tr(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "tap_the_button_below_to_add_an_event".tr(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: eventProvider.events.length,
            itemBuilder: (context, index) {
              final event = eventProvider.events[index];

              // Katılımcıları List<String> olarak düzenleme
              final people = (event['people'] as List<dynamic>)
                  .map((person) =>
                      person is Map<String, dynamic> ? person['name'].toString() : person.toString())
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
                        uniqueId: '', // Doğru uniqueId eklenmeli
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
                        ...people.map((person) => Text(person)),
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

  Widget _buildSettingsPage() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Kullanıcı oturum açmamış."));
    }

    // Firebase'deki kullanıcının email'ine göre belgeyi bul
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get(), // Email alanına göre sorgulama
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Veri alınırken hata oluştu."));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Kullanıcı bilgileri bulunamadı."));
        }

        // Veriyi alalım
        var userDoc = snapshot.data!.docs.first;
        String userName = userDoc['name'] ?? "Kullanıcı Adı";
        String userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.purple,
                child: Text(
                  userInitial,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                userName,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        );
      },
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
