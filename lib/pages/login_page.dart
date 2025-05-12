import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  String erro = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Firebase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await AuthService.loginWithEmail(
                  emailController.text,
                  senhaController.text,
                );
                if (result != null) setState(() => erro = result);
              },
              child: const Text('Entrar com Email'),
            ),
            TextButton(
              onPressed: () async {
                final result = await AuthService.registerWithEmail(
                  emailController.text,
                  senhaController.text,
                );
                if (result != null) setState(() => erro = result);
              },
              child: const Text('Registrar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.g_mobiledata),
              onPressed: () async {
                final result = await AuthService.loginWithGoogle();
                if (result != null) setState(() => erro = result);
              },
              label: const Text('Entrar com Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            if (erro.isNotEmpty)
              Text(erro, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
