import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/providers.dart';

/// Memeriksa custom claim admin lalu mengarahkan ke beranda atau dashboard admin.
class RoleGateScreen extends ConsumerStatefulWidget {
  const RoleGateScreen({super.key});
  @override
  ConsumerState<RoleGateScreen> createState() => _RoleGateScreenState();
}

class _RoleGateScreenState extends ConsumerState<RoleGateScreen> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    bool admin = false;
    try {
      admin = await ref.read(authServiceProvider).isAdmin();
    } catch (_) {
      admin = false;
    }
    if (mounted) context.go(admin ? '/admin' : '/home');
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
      );
}
