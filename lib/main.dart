import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:manpower/onboarding_screen.dart';
import 'package:manpower/secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
void backgroundNotificationListener(Map<String, dynamic> data) {
  // Print notification payload data

  // Notification title
  String notificationTitle = 'ManPower';

  // Attempt to extract the "message" property from the payload: {"message":"Hello World!"}
  String notificationText = data['message'] ?? 'Hello World!';

  // Android: Displays a system notification
  Pushy.notify(notificationTitle, notificationText, data);

  // Clear iOS app badge number
  Pushy.clearBadge();
}


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

class DevicePreviewApp extends StatefulWidget {
  const DevicePreviewApp({super.key});

  @override
  State<DevicePreviewApp> createState() => _DevicePreviewAppState();
}

class _DevicePreviewAppState extends State<DevicePreviewApp> {
  @override
  void initState(){
    super.initState();
    Pushy.listen();
  }
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState(){
    super.initState();
    Pushy.listen();
  }
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

