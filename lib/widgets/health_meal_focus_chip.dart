import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import '../coaching/meal_focus_icon.dart';

/// Health consideration chip with leading icon (sign-up & coaching profile).
class HealthMealFocusChip extends StatelessWidget {
  const HealthMealFocusChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.height,
    required this.fontSize,
    required this.selectedBackground,
    required this.unselectedBackground,
    required this.outlineColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;
  final Color selectedBackground;
  final Color unselectedBackground;
  final Color outlineColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? selectedTextColor : unselectedTextColor;
    final iconColor = selected ? selectedTextColor : unselectedTextColor;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedBackground : unselectedBackground,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: selected ? selectedBackground : outlineColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mealFocusIconFor(label),
              size: (fontSize + 2).sp,
              color: iconColor,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
