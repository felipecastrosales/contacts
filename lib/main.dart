import 'package:flutter/material.dart';

import 'ui/home_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        primaryColor: Colors.red,
        dialogBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(const Color(0x22000000)),
          ),
        ),
      ),
    ),
  );
}
