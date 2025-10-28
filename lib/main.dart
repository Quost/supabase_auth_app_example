import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseUrl = "https://jekvfatqxupkokkbxyan.supabase.co";
  final supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impla3ZmYXRxeHVwa29ra2J4eWFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwNzI0NjAsImV4cCI6MjA3NjY0ODQ2MH0._V2XV1-wJ14c2oST04D35AJv78G79dPVhEaGeDoYe60";

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      detectSessionInUri: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Auth Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0057B8),
        brightness: Brightness.light,
      ),
      home: const AuthGate(),
    );
  }
}
