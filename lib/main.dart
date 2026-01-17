import 'package:invitaciones/dos.dart';
import 'package:invitaciones/tres.dart';
import 'package:invitaciones/fotos.dart'; // IMPORT AGREGADO
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD9-Pc4sDR5rhP3j-4ssqnEHQByuGRdXMg",
        authDomain: "invitacione-be055.firebaseapp.com",
        projectId: "invitacione-be055",
        storageBucket: "invitacione-be055.appspot.com",
        messagingSenderId: "579598960369",
        appId: "1:579598960369:web:2dc0748a73a722345c0b50",
        measurementId: "G-S6Q26RFBM8",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Itzel & Oscar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        // RUTA PARA DOS
        if (uri.path == '/dos' || uri.path == 'dos') {
          final queryParams = uri.queryParameters;

          return MaterialPageRoute(
            builder: (_) => const Dos(),
            settings: RouteSettings(
              name: '/dos',
              arguments: queryParams.isNotEmpty ? queryParams : null,
            ),
          );
        }

        // RUTA PARA TRES
        if (uri.path == '/tres' || uri.path == 'tres') {
          return MaterialPageRoute(
            builder: (_) => const Tres(),
            settings: const RouteSettings(name: '/tres'),
          );
        }

        // RUTA PARA FOTOS - AGREGADA AQUÍ
        if (uri.path == '/fotos' || uri.path == 'fotos') {
          return MaterialPageRoute(
            builder: (_) => const Fotos(),
            settings: const RouteSettings(name: '/fotos'),
          );
        }

        // RUTA POR DEFECTO (HOME)
        if (uri.path == '/' || uri.path.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const Dos(),
            settings: const RouteSettings(name: '/'),
          );
        }

        // FALLBACK - CUALQUIER OTRA RUTA
        return MaterialPageRoute(
          builder: (_) => const Dos(),
          settings: const RouteSettings(name: '/'),
        );
      },
      initialRoute: '/',
    );
  }
}