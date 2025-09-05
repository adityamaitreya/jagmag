import 'package:flutter/material.dart';
import 'package:jagmag/main.dart';
import 'package:jagmag/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialRouteManager extends StatefulWidget {
  const InitialRouteManager({super.key});

  @override
  State<InitialRouteManager> createState() => _InitialRouteManagerState();
}

class _InitialRouteManagerState extends State<InitialRouteManager> {
  late Future<bool> _isFirstLaunchFuture;

  @override
  void initState() {
    super.initState();
    _isFirstLaunchFuture = _checkFirstLaunch();
  }

  Future<bool> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('first_launch', false);
    }
    return isFirstLaunch;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstLaunchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          final bool isFirstLaunch = snapshot.data ?? true;
          return isFirstLaunch
              ? const WelcomeScreen()
              : const InitialAuthCheck();
        }
      },
    );
  }
}
