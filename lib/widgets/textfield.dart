import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String label;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final bool isIOS;

  const CustomTextField({
    Key? key,
    required this.hint,
    required this.label,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.isIOS = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacing_xs),
          ],
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.grey[100] : Colors.grey[50],
              borderRadius: BorderRadius.circular(AppTheme.radius_lg),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 0.5,
              ),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: isPassword,
              validator: validator,
              keyboardType: keyboardType,
              enabled: enabled,
              maxLines: maxLines,
              maxLength: maxLength,
              textInputAction: textInputAction,
              onFieldSubmitted: onSubmitted,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: -0.5,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppTheme.textSecondaryColor.withOpacity(0.7),
                  fontSize: 17,
                  letterSpacing: -0.5,
                ),
                prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondaryColor) : null,
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing_md,
                  vertical: AppTheme.spacing_md,
                ),
                counterText: "",
              ),
            ),
          ),
        ],
      );
    }

    // Fallback to Material design
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacing_xs),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius_sm),
            ),
          ),
        ),
      ],
    );
  }
}