import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/providers.dart';
import '../../services/auth_service.dart';
import 'auth_scaffold.dart';
import 'validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider)
          .login(email: _email.text, password: _password.text);
      if (mounted) context.go('/gate');
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Selamat Datang!',
      subtitle: 'Masuk untuk melanjutkan perjalananmu.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _hide,
              validator: Validators.password,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(label: 'Masuk', loading: _loading, onPressed: _submit),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun? '),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: const Text('Daftar',
                      style: TextStyle(
                          color: AppColors.terracotta, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
