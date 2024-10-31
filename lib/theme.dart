import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services library
import 'theme.dart'; // Import the theme file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World App',
      theme: MyDarkTheme.themeData,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => SystemNavigator.pop(), // Close the app
          ),
        ],
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }
}



class MyDarkTheme {
  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        titleTextStyle: TextStyle(color: Colors.green, fontSize: 20),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white), // Correctly placed inside TextTheme
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.green,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // Background color
          foregroundColor: Colors.black, // Text color
        ),
      ),
    );
  }
}