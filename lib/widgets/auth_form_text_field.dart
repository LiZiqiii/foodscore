import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fixed-height auth form field with vertically centered text and hint.
class AuthFormTextField extends StatelessWidget {
  const AuthFormTextField({
    super.key,
    required this.height,
    required this.hint,
    required this.backgroundColor,
    required this.borderColor,
    required this.errorBorderColor,
    required this.textColor,
    required this.hintColor,
    required this.fontSize,
    required this.hintFontSize,
    required this.borderRadius,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.hasError = false,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.useShadow = true,
  });

  final double height;
  final String hint;
  final Color backgroundColor;
  final Color borderColor;
  final Color errorBorderColor;
  final Color textColor;
  final Color hintColor;
  final double fontSize;
  final double hintFontSize;
  final double borderRadius;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final bool hasError;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool useShadow;

  @override
  Widget build(BuildContext context) {
    final fieldHeight = height.h;
    final activeBorder = hasError ? errorBorderColor : borderColor;
    // Obscured fields must stay single-line (Flutter asserts otherwise).
    final isObscured = obscureText;

    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: activeBorder, width: 1),
        boxShadow: useShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF1A6731).withValues(alpha: 0.04),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        expands: !isObscured,
        maxLines: isObscured ? 1 : null,
        minLines: isObscured ? 1 : null,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.0,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: hintFontSize.sp,
            fontWeight: FontWeight.w400,
            color: hintColor,
            height: 1.0,
          ),
          filled: true,
          fillColor: backgroundColor,
          isDense: true,
          contentPadding: EdgeInsets.only(
            left: 16.w,
            right: suffixIcon != null ? 4.w : 16.w,
            top: isObscured ? (fieldHeight - fontSize.sp) / 2 : 0,
            bottom: isObscured ? (fieldHeight - fontSize.sp) / 2 : 0,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          suffixIcon: suffixIcon,
          suffixIconConstraints: BoxConstraints(
            minWidth: 40.w,
            minHeight: fieldHeight,
          ),
        ),
      ),
    );
  }
}
