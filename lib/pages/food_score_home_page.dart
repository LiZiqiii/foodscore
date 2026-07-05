import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import 'food_score_home_controller.dart';
import 'share_meal_page.dart';

/// FoodScore 首页 / Onboarding。
class FoodScoreHomePage extends StatelessWidget {
  const FoodScoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodScoreHomeController.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: FoodScoreHomeController.horizontalPadding.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: FoodScoreHomeController.topExtraPadding.h),
              _buildHeroSection(),
              SizedBox(height: 18.h),
              _buildDescription(),
              SizedBox(height: 18.h),
              _buildFeatureList(),
              SizedBox(height: 30.h),
              _buildCtaButton(context),
              SizedBox(height: FoodScoreHomeController.ctaToDisclaimerGap.h),
              _buildDisclaimer(),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: FoodScoreHomeController.heroHeight.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: FoodScoreHomeController.heroHeight.h,
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 14.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FoodScoreHomeController.heroGradientStart,
                  FoodScoreHomeController.heroGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(
                FoodScoreHomeController.heroRadius.r,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A6731).withValues(alpha: 0.07),
                  blurRadius: 14.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FoodScoreHomeController.brandName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: FoodScoreHomeController.brandColor,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 18.h),
                _buildHeadlineLine(FoodScoreHomeController.headlineLine1),
                _buildHeadlineLine(FoodScoreHomeController.headlineLine2),
                _buildHeadlineLine(FoodScoreHomeController.headlineLine3),
              ],
            ),
          ),
          Positioned(
            right: -4.w,
            bottom: -22.h,
            child: Image.asset(
              FoodScoreHomeController.mealImageAsset,
              width: FoodScoreHomeController.mealImageWidth.w,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineLine(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FoodScoreHomeController.headlineFontSize.sp,
        fontWeight: FontWeight.w600,
        color: FoodScoreHomeController.headlineColor,
        height: 1.24,
        letterSpacing: -0.2,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.10),
            offset: Offset(0, 1.5.h),
            blurRadius: 3.r,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      FoodScoreHomeController.description,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: FoodScoreHomeController.descriptionColor,
        height: 1.5,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        for (var i = 0; i < FoodScoreHomeController.features.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          _buildFeatureRow(FoodScoreHomeController.features[i]),
        ],
      ],
    );
  }

  Widget _buildFeatureRow(HomeFeatureItem item) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: FoodScoreHomeController.featureIconBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            item.icon,
            size: 18.sp,
            color: FoodScoreHomeController.featureIconColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: FoodScoreHomeController.featureTextColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(24.r);

    return Center(
      child: Material(
        color: FoodScoreHomeController.ctaColor,
        elevation: 2.5,
        shadowColor: FoodScoreHomeController.ctaColor.withValues(alpha: 0.28),
        borderRadius: borderRadius,
        clipBehavior: Clip.none,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ShareMealPage(),
              ),
            );
          },
          borderRadius: borderRadius,
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: SizedBox(
            width: FoodScoreHomeController.ctaMaxWidth.w,
            height: FoodScoreHomeController.ctaHeight.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  FoodScoreHomeController.ctaLabel,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.15,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Center(
      child: Text(
        '${FoodScoreHomeController.disclaimerLine1}\n'
        '${FoodScoreHomeController.disclaimerLine2}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: FoodScoreHomeController.disclaimerColor,
          height: 1.4,
        ),
      ),
    );
  }
}
