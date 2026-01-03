import 'package:emart_app/Screens/Auth/login_signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- ADD THIS
import 'Screens/Auth/login.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB_vavjrX4m1VLo-iruMjfXU65fsO-LPZs",
      authDomain: "meddocapp-77e7a.firebaseapp.com",
      projectId: "meddocapp-77e7a",
      storageBucket: "meddocapp-77e7a.firebasestorage.app",
      messagingSenderId: "86191262434",
      appId: "1:86191262434:web:f2b242a3e8da9fed7eacbb",
    ),
  );

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  runApp(const MedDocApp());
}

class MedDocApp extends StatelessWidget {
  const MedDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialisation de ResponsiveSizer
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MedDoc',
          home: const login_signup(),
        );
      },
    );
  }
}
