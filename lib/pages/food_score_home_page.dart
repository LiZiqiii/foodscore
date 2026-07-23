import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import 'food_score_home_controller.dart';
import '../config/page_layout.dart';
import 'share_meal_page.dart';
import '../widgets/user_menu_drawer.dart';
import 'weekly_reflection_page.dart';

/// FoodScore 首页 / Onboarding。
class FoodScoreHomePage extends StatelessWidget {
  const FoodScoreHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodScoreHomeController.backgroundColor,
      endDrawer: const UserMenuDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: FoodScoreHomeController.horizontalPadding.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(scaffoldContext),
                    SizedBox(
                      height: (FoodScoreHomeController.topExtraPadding +
                              FoodScoreHomeController.heroContentTopGap)
                          .h,
                    ),
                    _buildWelcomeCard(),
                    SizedBox(
                      height: FoodScoreHomeController.welcomeToFeaturesGap.h,
                    ),
                    _buildFeatureList(),
                    SizedBox(
                      height: FoodScoreHomeController.featuresToCtaGap.h,
                    ),
                    _buildCtaButton(scaffoldContext),
                    SizedBox(
                      height: FoodScoreHomeController.ctaToReflectionGap.h,
                    ),
                    _buildReflectionEntry(scaffoldContext),
                    SizedBox(
                      height:
                          FoodScoreHomeController.reflectionToDisclaimerGap.h,
                    ),
                    _buildDisclaimer(),
                    SizedBox(
                      height: FoodScoreHomeController.disclaimerBottomPadding.h,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: FoodScoreHomeController.brandTopInset.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            FoodScoreHomeController.brandName,
            style: TextStyle(
              fontSize: FoodScoreHomeController.brandFontSize.sp,
              fontWeight: FontWeight.w700,
              color: FoodScoreHomeController.brandColor,
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              customBorder: const CircleBorder(),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  color: FoodScoreHomeController.userAvatarBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      height: FoodScoreHomeController.welcomeCardHeight.h,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 10.w, 18.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FoodScoreHomeController.welcomeGradientStart,
            FoodScoreHomeController.welcomeGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(
          FoodScoreHomeController.welcomeCardRadius.r,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A6731).withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  FoodScoreHomeController.welcomeTitleLine1,
                  style: TextStyle(
                    fontSize: FoodScoreHomeController.welcomeTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                    color: FoodScoreHomeController.welcomeTitleColor,
                    height: 1.2,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18.w, top: 4.h),
                  child: Text(
                    FoodScoreHomeController.welcomeTitleLine2,
                    style: TextStyle(
                      fontSize: FoodScoreHomeController.welcomeTitleFontSize.sp,
                      fontWeight: FontWeight.w600,
                      color: FoodScoreHomeController.welcomeTitleColor,
                      height: 1.15,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  FoodScoreHomeController.welcomeSubtitle,
                  style: TextStyle(
                    fontSize:
                        FoodScoreHomeController.welcomeSubtitleFontSize.sp,
                    fontWeight: FontWeight.w400,
                    color: FoodScoreHomeController.welcomeSubtitleColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height:
                (FoodScoreHomeController.welcomeCardHeight - 36).h,
            child: Image.asset(
              FoodScoreHomeController.mealImageAsset,
              width: FoodScoreHomeController.welcomeMealImageWidth.w,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        for (var i = 0; i < FoodScoreHomeController.features.length; i++) ...[
          if (i > 0)
            SizedBox(height: FoodScoreHomeController.featureRowGap.h),
          _buildFeatureRow(FoodScoreHomeController.features[i]),
        ],
      ],
    );
  }

  Widget _buildFeatureRow(HomeFeatureItem item) {
    return Row(
      children: [
        Container(
          width: FoodScoreHomeController.featureIconBoxSize.w,
          height: FoodScoreHomeController.featureIconBoxSize.w,
          decoration: BoxDecoration(
            color: FoodScoreHomeController.featureIconBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            item.icon,
            size: FoodScoreHomeController.featureIconSize.sp,
            color: FoodScoreHomeController.featureIconColor,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: FoodScoreHomeController.featureFontSize.sp,
              fontWeight: FontWeight.w500,
              color: FoodScoreHomeController.featureTextColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      PageLayout.primaryButtonRadius.r,
    );

    return Material(
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
          width: double.infinity,
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
    );
  }

  Widget _buildReflectionEntry(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      FoodScoreHomeController.reflectionCardRadius.r,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WeeklyReflectionPage(),
            ),
          );
        },
        borderRadius: borderRadius,
        splashColor: FoodScoreHomeController.ctaColor.withValues(alpha: 0.05),
        highlightColor: FoodScoreHomeController.ctaColor.withValues(
          alpha: 0.02,
        ),
        child: Container(
          width: double.infinity,
          height: FoodScoreHomeController.reflectionCardHeight.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: FoodScoreHomeController.backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: FoodScoreHomeController.reflectionBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  FoodScoreHomeController.reflectionTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: FoodScoreHomeController.reflectionTitleColor,
                    height: 1.15,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16.sp,
                color: FoodScoreHomeController.reflectionArrowColor,
              ),
            ],
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
