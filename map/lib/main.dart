import 'package:flutter/material.dart';

import 'package:map/map/presentation/views/map_page.dart';
import 'package:map/core/di/injection_container.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MapPage());
  }
}
