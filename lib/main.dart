import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:project_contapp/screens/contacts_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.pink.shade400,
        scaffoldBackgroundColor: const Color(0xFFFFF1F6),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade400,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24.0)),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.pinkAccent,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink).copyWith(
          secondary: Colors.pinkAccent,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(const Color(0x22FFB6C1)),
          ),
        ),
      ),
      home: const ContactsPage(),
    );
  }
}
