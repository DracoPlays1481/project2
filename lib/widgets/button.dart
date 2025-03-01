import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final ButtonSize size;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.size = ButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define sizes based on the ButtonSize enum
    final double height = size == ButtonSize.small
        ? 36
        : size == ButtonSize.medium
        ? 48
        : 56;

    final double fontSize = size == ButtonSize.small
        ? 14
        : size == ButtonSize.medium
        ? 16
        : 18;

    final double iconSize = size == ButtonSize.small
        ? 18
        : size == ButtonSize.medium
        ? 20
        : 24;

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
      foregroundColor: backgroundColor ?? theme.primaryColor,
      side: BorderSide(
        color: backgroundColor ?? theme.primaryColor,
        width: 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_md,
        vertical: AppTheme.spacing_sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius_sm),
      ),
      alignment: Alignment.center,
    )
        : ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: textColor ?? Colors.white,
      elevation: 2,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing_md,
        vertical: AppTheme.spacing_sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius_sm),
      ),
      alignment: Alignment.center,
    );

    final button = SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: _buildButtonContent(
          context,
          fontSize,
          iconSize,
          backgroundColor ?? theme.primaryColor,
        ),
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: _buildButtonContent(
          context,
          fontSize,
          iconSize,
          Colors.white,
        ),
      ),
    );

    return button;
  }

  Widget _buildButtonContent(
      BuildContext context,
      double fontSize,
      double iconSize,
      Color loadingColor,
      ) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: loadingColor,
          strokeWidth: 2,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize),
          SizedBox(width: AppTheme.spacing_sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      // For buttons without icons, use a centered text directly
      return Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}

enum ButtonSize {
  small,
  medium,
  large,
}