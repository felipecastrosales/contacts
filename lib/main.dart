import 'package:flutter/material.dart';
import 'ui/home_page.dart';
void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: HomePage(),
  theme: ThemeData(
    primaryColor: Colors.red,
    accentColor: Colors.red),
));