import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

/// Shared meal-feedback disclaimer copy and layout (Home full / flow pages compact).
abstract final class MealFeedbackDisclaimerCopy {
  static const String line1 = 'Approximate meal-level feedback.';
  static const String line2 =
      'Not medical advice or precise nutrient calculation.';
  static const String compactLine = 'Not medical advice.';
  static const String learnMoreLabel = 'About this feedback';

  static const Color textColor = Color(0xFF8A8C88);
  static const double fontSize = 12;
  static const double lineHeight = 1.4;

  /// SafeArea bottom padding below disclaimer on all meal-flow screens.
  static const double bottomInset = 24;

  static String get fullText => '$line1\n$line2';
}

enum MealFeedbackDisclaimerStyle { full, compact }

class MealFeedbackDisclaimer extends StatelessWidget {
  const MealFeedbackDisclaimer({
    super.key,
    this.style = MealFeedbackDisclaimerStyle.full,
  });

  final MealFeedbackDisclaimerStyle style;

  static void showFullDisclaimerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MealFeedbackDisclaimerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case MealFeedbackDisclaimerStyle.full:
        return Center(
          child: Text(
            MealFeedbackDisclaimerCopy.fullText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MealFeedbackDisclaimerCopy.fontSize.sp,
              fontWeight: FontWeight.w400,
              color: MealFeedbackDisclaimerCopy.textColor,
              height: MealFeedbackDisclaimerCopy.lineHeight,
            ),
          ),
        );
      case MealFeedbackDisclaimerStyle.compact:
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4.w,
            children: [
              Text(
                MealFeedbackDisclaimerCopy.compactLine,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MealFeedbackDisclaimerCopy.fontSize.sp,
                  fontWeight: FontWeight.w400,
                  color: MealFeedbackDisclaimerCopy.textColor,
                  height: MealFeedbackDisclaimerCopy.lineHeight,
                ),
              ),
              GestureDetector(
                onTap: () => showFullDisclaimerSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  MealFeedbackDisclaimerCopy.learnMoreLabel,
                  style: TextStyle(
                    fontSize: MealFeedbackDisclaimerCopy.fontSize.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A6B52),
                    height: MealFeedbackDisclaimerCopy.lineHeight,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF4A6B52).withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _MealFeedbackDisclaimerSheet extends StatelessWidget {
  const _MealFeedbackDisclaimerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              MealFeedbackDisclaimerCopy.learnMoreLabel,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A4B48),
                height: 1.25,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              MealFeedbackDisclaimerCopy.fullText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF767676),
                height: 1.45,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 48.h,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF165529),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom disclaimer + standard inset for meal input / share screens.
class MealFeedbackDisclaimerFooter extends StatelessWidget {
  const MealFeedbackDisclaimerFooter({
    super.key,
    this.style = MealFeedbackDisclaimerStyle.compact,
  });

  final MealFeedbackDisclaimerStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MealFeedbackDisclaimer(style: style),
        SizedBox(height: MealFeedbackDisclaimerCopy.bottomInset.h),
      ],
    );
  }
}
