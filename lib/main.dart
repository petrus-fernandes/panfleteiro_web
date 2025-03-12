import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'anuncio_service.dart';
import 'anuncio_list.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AnuncioService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produtos App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnuncioList(),
    );
  }
}