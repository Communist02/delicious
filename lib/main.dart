import 'package:flutter/material.dart';
import 'firebase.dart';
import 'home.dart';
import 'themes.dart';
import 'global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'state_update.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final theme = prefs.getString('theme');
  if (theme != null) appSettings['theme'] = theme;

  final ordersSort = prefs.getString('ordersSort');
  if (ordersSort != null) appSettings['ordersSort'] = ordersSort;

  final search = prefs.getStringList('searchHistory');
  if (search != null) searchHistory.history = search;

  final basket = prefs.getString('basket');
  if (basket != null) globalBasket.products = globalBasket.fromMap(jsonDecode(basket));

  await Firebase.initializeApp();
  AuthService().sign();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChangeReservations()),
        ChangeNotifierProvider(create: (context) => ChangeBasket()),
        ChangeNotifierProvider(create: (context) => ChangeNavigation()),
        ChangeNotifierProvider(
          create: (context) => ChangeTheme(),
          builder: (BuildContext context, _) {
            context.watch<ChangeTheme>().getTheme;
            return MaterialApp(
              title: 'Restaurant',
              themeMode: AppThemes.getMode(appSettings['theme']!),
              theme: AppThemes.light(),
              darkTheme: AppThemes.dark(),
              home: const HomePage(),
            );
          },
        ),
      ],
    );
  }
}
