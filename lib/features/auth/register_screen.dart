import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/providers.dart';
import '../../services/auth_service.dart';
import 'auth_scaffold.dart';
import 'validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).register(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          );
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
      title: 'Mulai Petualangan',
      subtitle: 'Buat akun untuk menjelajahi budaya Lampung.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: Validators.name,
              decoration: const InputDecoration(
                  labelText: 'Nama lengkap', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 14),
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
              textInputAction: TextInputAction.next,
              validator: Validators.password,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirm,
              obscureText: _hide,
              validator: (v) =>
                  v != _password.text ? 'Konfirmasi password tidak sama' : null,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                  labelText: 'Konfirmasi password',
                  prefixIcon: Icon(Icons.lock_reset_outlined)),
            ),
            const SizedBox(height: 22),
            PrimaryButton(label: 'Daftar', loading: _loading, onPressed: _submit),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah punya akun? '),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Text('Masuk',
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
