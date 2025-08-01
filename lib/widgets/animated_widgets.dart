import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Duration delay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.borderRadius,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: color,
      elevation: elevation ?? 4,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutQuart);
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final bool isValid;
  final IconData? icon;
  final Duration delay;

  const StatusChip({
    super.key,
    required this.label,
    required this.isValid,
    this.icon,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isValid 
            ? (isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1))
            : (isDark ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isValid ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isValid ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 400.ms);
  }
}

class PulsatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const PulsatingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: size)
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.2, 1.2),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(1.0, 1.0),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: isDark ? Colors.grey[700] : Colors.grey[100],
        );
  }
}

class FloatingActionButtonAnimated extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final bool isEnabled;

  const FloatingActionButtonAnimated({
    super.key,
    this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isEnabled ? onPressed : null,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      child: child,
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 300.ms);
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Gradient gradient;
  final double? width;
  final double height;
  final bool isLoading;
  final Duration delay;

  const GradientButton({
    super.key,
    this.onPressed,
    required this.text,
    required this.gradient,
    this.width,
    this.height = 50,
    this.isLoading = false,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : LinearGradient(
          colors: [Colors.grey, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}
