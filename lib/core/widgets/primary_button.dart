import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tombol utama terracotta dengan micro-interaction tekan (scale) dan loading.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color = AppColors.terracotta,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color color;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _enabled
                  ? [widget.color, AppColors.terracottaDark]
                  : [widget.color.withValues(alpha: 0.5), widget.color.withValues(alpha: 0.5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _pressed ? 0.15 : 0.35),
                blurRadius: _pressed ? 4 : 12,
                offset: Offset(0, _pressed ? 2 : 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
