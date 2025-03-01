import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool isIOS;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.isIOS = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radius_md);

    if (isIOS) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(AppTheme.spacing_md),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    // Fallback to Material card
    return Card(
      elevation: elevation ?? 1,
      color: backgroundColor ?? Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacing_md),
          child: child,
        ),
      ),
    );
  }
}