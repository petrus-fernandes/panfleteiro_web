import 'package:flutter/material.dart';
import 'package:panfleteiro_web/screens/validacao_screen.dart';
import 'package:provider/provider.dart';
import 'services/anuncio_service.dart';
import 'screens/anuncio_main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFFAE567),
          brightness: Brightness.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/main',
      routes: {
        '/main': (context) => AnuncioMainScreen(),
        '/login': (context) => LoginScreen(),
        '/validacao': (context) => ValidacaoScreen(),
      },
    );
  }
}
