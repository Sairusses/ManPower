import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:manpower/onboarding_screen.dart';
import 'package:manpower/secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true
  );
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  if(kIsWeb){
    runApp(
        DevicePreview(
          enabled: true,
          builder: (context) => const DevicePreviewApp(),
        )
    );
  }else{
    runApp(MyApp());
  }
}

class DevicePreviewApp extends StatelessWidget {
  const DevicePreviewApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData.light(),
        darkTheme: ThemeData.light(),
        home: OnboardingScreen()
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.light(),
        home: OnboardingScreen()
    );
  }
}

