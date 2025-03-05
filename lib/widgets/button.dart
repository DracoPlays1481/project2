import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  final bool isIOS;

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
    this.isIOS = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define sizes based on the ButtonSize enum
    final double height = size == ButtonSize.small
        ? 36
        : size == ButtonSize.medium
        ? 44
        : 50;

    final double fontSize = size == ButtonSize.small
        ? 14
        : size == ButtonSize.medium
        ? 16
        : 17;

    final double iconSize = size == ButtonSize.small
        ? 18
        : size == ButtonSize.medium
        ? 20
        : 22;

    // Calculate horizontal padding based on button size
    final double horizontalPadding = size == ButtonSize.small
        ? 12
        : size == ButtonSize.medium
        ? 16
        : 20;

    // iOS-style button
    if (isIOS) {
      if (isOutlined) {
        return SizedBox(
          width: width,
          height: height,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: isLoading ? null : onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: backgroundColor ?? AppTheme.primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(height / 2),
              ),
              alignment: Alignment.center,
              child: _buildButtonContent(
                context,
                fontSize,
                iconSize,
                backgroundColor ?? AppTheme.primaryColor,
                true,
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          width: width,
          height: height,
          child: CupertinoButton.filled(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            onPressed: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(height / 2),
            disabledColor: (backgroundColor ?? AppTheme.primaryColor).withOpacity(0.5),
            child: _buildButtonContent(
              context,
              fontSize,
              iconSize,
              Colors.white,
              false,
            ),
          ),
        );
      }
    }

    // Material button as fallback
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
      foregroundColor: backgroundColor ?? theme.primaryColor,
      side: BorderSide(
        color: backgroundColor ?? theme.primaryColor,
        width: 1,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppTheme.spacing_sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(height / 2),
      ),
      alignment: Alignment.center,
    )
        : ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: textColor ?? Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppTheme.spacing_sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(height / 2),
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
          true,
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
          false,
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
      bool isOutlined,
      ) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: isIOS
            ? CupertinoActivityIndicator(color: loadingColor)
            : CircularProgressIndicator(
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
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
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
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

enum ButtonSize {
  small,
  medium,
  large,
}