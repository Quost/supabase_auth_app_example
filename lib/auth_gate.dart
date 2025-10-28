import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';
import 'pages/sign_in_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    final initialSession = supabase.auth.currentSession;

    return StreamBuilder<AuthState>(
      initialData: initialSession != null
          ? AuthState(AuthChangeEvent.signedIn, initialSession)
          : const AuthState(AuthChangeEvent.signedOut, null),
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) return const SignInPage();
        return const HomePage();
      },
    );
  }
}
