import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

/// Registro: crea la cuenta en Firebase Auth y el perfil en Firestore.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    final error = await AppController.to.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Crear cuenta', style: outfit(27, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Configura tu perfil para comenzar.', style: inter(14, color: AppColors.mutedForeground)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
                  validator: Validators.name,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña (mínimo 8 caracteres)', prefixIcon: Icon(Icons.lock_outline)),
                  validator: Validators.newPassword,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 50,
                  child: Obx(() {
                    final busy = AppController.to.busy;
                    return FilledButton(
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Crear cuenta'),
                    );
                  }),
                ),
                TextButton(
                  onPressed: () => AppController.to.go(AppScreen.login),
                  child: const Text('Ya tengo cuenta · Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
