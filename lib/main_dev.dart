import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:nansan_flutter/app_module.dart';
import 'package:nansan_flutter/modules/network_check/no_internet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ModularApp(module: AppModule(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<InternetStatus> _subscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        _hasInternet = status == InternetStatus.connected;
      });
    });
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final status = await InternetConnection().hasInternetAccess;
    setState(() {
      _hasInternet = status;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return MaterialApp(
        home: NoInternetScreen(onRetry: _checkInitialConnection),
      );
    }
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nansan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFFFBF4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBF4),
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
