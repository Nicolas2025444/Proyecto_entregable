import 'package:flutter/material.dart';
import 'package:proyecto_3/providers/auth_provider.dart';
import 'package:proyecto_3/ui/screens/login_screen.dart';
import 'package:proyecto_3/ui/screens/medico_home_screen.dart';
import 'package:proyecto_3/ui/screens/paciente_home_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.unknown) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isAuthenticated && auth.user != null) {
      final user = auth.user!;
      return user.isPaciente
          ? PacienteHomeScreen(user: user)
          : MedicoHomeScreen(user: user);
    }

    return const LoginScreen();
  }
}
