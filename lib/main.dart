
import 'package:app1/test/Services/firebase_service.dart';
import 'package:app1/test/pages/register.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


import 'firebase_options.dart';
import 'test/pages/login.dart';
import 'test/pages/register.dart';


Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotif();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      //home: const WidgetTree(),
      home: LoginPage(),
      routes: {

        'Register': (context) => Register(),  // Make sure this matches
      },
    );
  }
}



