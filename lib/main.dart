import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/dos.dart';
import 'package:flutter_firebase/tres.dart';


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
      print('=== ROUTE DEBUG ===');
      print('Settings name: ${settings.name}');
      print('Settings arguments: ${settings.arguments}');
      
      // En Flutter Web con hash routing, la ruta completa viene en settings.name
      // Puede ser algo como: "/dos?id=xxx" o simplemente "/dos"
      final uri = Uri.parse(settings.name ?? '/');
      print('Parsed URI path: ${uri.path}');
      print('Parsed URI query: ${uri.queryParameters}');
      
      // Ruta para 'dos' (invitaciones)
      if (uri.path == '/dos' || uri.path == 'dos') {
        final queryParams = uri.queryParameters;
        print('Query params para dos: $queryParams');
        
        return MaterialPageRoute(
          builder: (_) => const Dos(),
          settings: RouteSettings(
            name: '/dos',
            arguments: queryParams.isNotEmpty ? queryParams : null,
          ),
        );
      }
      
      // Ruta para 'tres' (admin)
      if (uri.path == '/tres' || uri.path == 'tres') {
        return MaterialPageRoute(
          builder: (_) => const Tres(),
          settings: const RouteSettings(name: '/tres'),
        );
      }
      
      // Ruta raíz - redirigir a 'dos'
      if (uri.path == '/' || uri.path.isEmpty) {
        return MaterialPageRoute(
          builder: (_) => const Dos(),
          settings: const RouteSettings(name: '/'),
        );
      }
      
      // Ruta por defecto
      print('Ruta no reconocida, usando default');
      return MaterialPageRoute(
        builder: (_) => const Dos(),
        settings: const RouteSettings(name: '/'),
      );
    },
    initialRoute: '/',
  );
}
}
