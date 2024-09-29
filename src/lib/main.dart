import 'package:fitness_planner/firebase_options.dart';
import 'package:fitness_planner/pages/Splash_page.dart';
import 'package:fitness_planner/services/EventProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.lightGreenAccent),
        home: SplashPage(),
      ),
    );
  }
}
