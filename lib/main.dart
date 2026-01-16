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
      // Usar onGenerateRoute en lugar de routes
      onGenerateRoute: (settings) {
        // Extraer la ruta y los parámetros
        final uri = Uri.parse(settings.name ?? '/');
        
        print('Navegando a: ${settings.name}');
        print('Path: ${uri.path}');
        print('Query params: ${uri.queryParameters}');
        
        // Ruta principal
        if (uri.path == '/' || uri.path.isEmpty) {
          return MaterialPageRoute(builder: (_) => const Dos());
        }
        
        // Ruta 'dos' con o sin parámetros
        if (uri.path == '/dos') {
          return MaterialPageRoute(
            builder: (_) => const Dos(),
            settings: RouteSettings(
              name: '/dos',
              arguments: uri.queryParameters,
            ),
          );
        }
        
        // Ruta 'tres' (admin)
        if (uri.path == 'tres') {
          return MaterialPageRoute(builder: (_) => const Tres());
        }
        
        // Ruta por defecto
        return MaterialPageRoute(builder: (_) => const Dos());
      },
      initialRoute: '/dos',
    );
  }
}
