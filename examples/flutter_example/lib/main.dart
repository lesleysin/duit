import 'package:flutter/material.dart';
import 'package:flutter_duit/flutter_duit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

@override
  Widget build(BuildContext context) {
    final driver = DUITDriver("/layout", transportOptions: HttpTransportOptions(defaultHeaders: {"Content-Type": "application/json"}, baseUrl: "http://localhost:8999"));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: Material(
        child: SafeArea(
          child: Column(
            children: [
              UIHostContainer(
                context: context,
                driver: driver,
                placeholder: const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
