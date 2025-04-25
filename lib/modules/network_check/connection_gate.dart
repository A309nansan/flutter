import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nansan_flutter/modules/network_check/no_internet_screen.dart';

class ConnectionGate extends StatefulWidget {
  final Widget child;
  const ConnectionGate({required this.child, super.key});

  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends State<ConnectionGate> {
  late StreamSubscription<InternetStatus> _subscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        _hasInternet = status == InternetStatus.connected;
      });
      if (_hasInternet) {
        // 인터넷이 복구되면 새로고침 또는 초기화
        // 예: Navigator.pushReplacement로 초기화
      }
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
      return NoInternetScreen(onRetry: _checkInitialConnection);
    }
    return widget.child;
  }
}
