import 'package:flutter/material.dart';
import 'package:flutter_duit/flutter_duit.dart';
import './src/registry_example.dart';

void main() {
  DUITRegistry.register(
    "ExampleCustomWidget",
    modelMapperExample,
    exampleRenderer,
    exampleAttributeMapper,
  );
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
    final driver = DUITDriver(
      "/form1",
      transportOptions: HttpTransportOptions(
        defaultHeaders: {"Content-Type": "application/json"},
        baseUrl: "http://localhost:8999",
      ),
    );
    // final driver = DUITDriver("ws://localhost:8999",
    //     transportOptions: WebSocketTransportOptions());
    return Scaffold(
      body: DuitViewHost(
        context: context,
        driver: driver,
        placeholder: const CircularProgressIndicator(),
      ),
    );
  }
}
