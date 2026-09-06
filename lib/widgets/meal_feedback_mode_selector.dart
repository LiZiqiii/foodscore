import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../pages/meal_analysis_loading_page.dart';

/// Feedback mode bottom sheet
abstract final class MealFeedbackModeCopy {
  static const String sheetTitle = 'How would you like feedback?';

  static const String instantTitle = 'Get instant feedback';
  static const String instantSubtitle =
      'See this meal\'s score, insights and tips now.';

  static const String reflectionTitle = 'Save for weekly reflection';
  static const String reflectionSubtitle =
      'Add this meal to your weekly summary without showing an immediate score.';

  static const String reflectionSavedMessage =
      'Meal saved for your weekly reflection.';

  static const Color titleColor = Color(0xFF4A4B48);
  static const Color subtitleColor = Color(0xFF878984);
  static const Color accentGreen = Color(0xFF1A6731);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE1EDE6);
  static const Color sheetBg = Color(0xFFF6FAF0);
}

Future<void> showMealFeedbackModeSheet(
  BuildContext context, {
  required VoidCallback onInstantFeedback,
  required VoidCallback onWeeklyReflection,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetContext) => _MealFeedbackModeSheet(
      onInstantFeedback: () {
        Navigator.of(sheetContext).pop();
        onInstantFeedback();
      },
      onWeeklyReflection: () {
        Navigator.of(sheetContext).pop();
        onWeeklyReflection();
      },
    ),
  );
}

void saveMealForWeeklyReflection(
  BuildContext context, {
  String? mealText,
  String? imagePath,
  XFile? imageFile,
  String? description,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MealAnalysisLoadingPage(
        mealText: mealText,
        imagePath: imagePath,
        imageFile: imageFile,
        description: description,
        saveForReflectionOnly: true,
      ),
    ),
  );
}

class _MealFeedbackModeSheet extends StatelessWidget {
  const _MealFeedbackModeSheet({
    required this.onInstantFeedback,
    required this.onWeeklyReflection,
  });

  final VoidCallback onInstantFeedback;
  final VoidCallback onWeeklyReflection;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MealFeedbackModeCopy.sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              MealFeedbackModeCopy.sheetTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inriaSerif(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: MealFeedbackModeCopy.titleColor,
                height: 1.25,
              ),
            ),
            SizedBox(height: 18.h),
            _ModeOptionCard(
              title: MealFeedbackModeCopy.instantTitle,
              subtitle: MealFeedbackModeCopy.instantSubtitle,
              emphasized: true,
              onTap: onInstantFeedback,
            ),
            SizedBox(height: 12.h),
            _ModeOptionCard(
              title: MealFeedbackModeCopy.reflectionTitle,
              subtitle: MealFeedbackModeCopy.reflectionSubtitle,
              emphasized: false,
              onTap: onWeeklyReflection,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  const _ModeOptionCard({
    required this.title,
    required this.subtitle,
    required this.emphasized,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = emphasized
        ? MealFeedbackModeCopy.accentGreen.withValues(alpha: 0.35)
        : MealFeedbackModeCopy.cardBorder;

    return Material(
      color: MealFeedbackModeCopy.cardBg,
      elevation: emphasized ? 1.5 : 0,
      shadowColor: MealFeedbackModeCopy.accentGreen.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: MealFeedbackModeCopy.accentGreen.withValues(alpha: 0.08),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: emphasized ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: MealFeedbackModeCopy.titleColor,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: MealFeedbackModeCopy.subtitleColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
