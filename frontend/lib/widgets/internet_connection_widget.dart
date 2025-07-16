import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionWidget extends StatefulWidget {
  final Widget child;
  const InternetConnectionWidget({super.key, required this.child});

  @override
  State<InternetConnectionWidget> createState() => _InternetConnectionWidgetState();
}

class _InternetConnectionWidgetState extends State<InternetConnectionWidget> {
  StreamSubscription<InternetStatus>? _subscription;
  bool _isDisconnected = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialConnection();
    });

    _subscription = InternetConnection().onStatusChange.listen((status) async {
      final hasInternet = await InternetConnection().hasInternetAccess;

      if (status == InternetStatus.disconnected && !hasInternet && !_isDisconnected) {
        _isDisconnected = true;
        _showNoInternetSnackBar();
      } else if (status == InternetStatus.connected && hasInternet && _isDisconnected) {
        _isDisconnected = false;
        _hideSnackBar();
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      _isDisconnected = true;
      _showNoInternetSnackBar();
    }
  }

  void _showNoInternetSnackBar() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection',
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _hideSnackBar() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
