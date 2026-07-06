import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'describe_meal_page.dart';
import '../config/page_layout.dart';
import '../widgets/page_back_button.dart';
import 'share_meal_page_controller.dart';
import 'upload_meal_photo_page.dart';

/// 选择分享餐食方式页面。
class ShareMealPage extends StatelessWidget {
  const ShareMealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShareMealPageController.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ShareMealPageController.horizontalPadding.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: PageLayout.topExtraPadding.h),
          const PageBackButton(),
          SizedBox(height: PageLayout.backToTitleGap.h),
          _buildTitleSection(),
          SizedBox(height: ShareMealPageController.titleToCardsGap.h),
          _buildPhotoCard(context),
          SizedBox(height: ShareMealPageController.cardGap.h),
          _buildTextCard(context),
          SizedBox(height: 58.h),
          _buildDisclaimer(),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ShareMealPageController.titleLine1,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: ShareMealPageController.titleColor,
            height: 1.25,
          ),
        ),
        Text(
          ShareMealPageController.titleLine2,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: ShareMealPageController.titleColor,
            height: 1.25,
          ),
        ),
        SizedBox(height: ShareMealPageController.titleToSubtitleGap.h),
        Text(
          ShareMealPageController.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ShareMealPageController.subtitleFontSize.sp,
            fontWeight: FontWeight.w400,
            color: ShareMealPageController.subtitleColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(BuildContext context) {
    final radius = BorderRadius.circular(
      ShareMealPageController.optionCardRadius.r,
    );

    return SizedBox(
      width: double.infinity,
      height: ShareMealPageController.optionCardHeight.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const UploadMealPhotoPage(),
              ),
            );
          },
          borderRadius: radius,
          splashColor: ShareMealPageController.photoIconColor.withValues(
            alpha: 0.08,
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: ShareMealPageController.photoCardBorder,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    ShareMealPageController.photoCardAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ShareMealPageController.optionCardPaddingH.w,
                    ),
                    child: _buildOptionCardCenter(
                      icon: Icon(
                        Icons.add_a_photo_outlined,
                        size: ShareMealPageController.optionIconSize.sp,
                        color: ShareMealPageController.photoIconColor,
                      ),
                      title: ShareMealPageController.photoCardTitle,
                    ),
                  ),
                  _buildOptionCardSubtitle(
                    ShareMealPageController.photoCardSubtitle,
                    ShareMealPageController.photoSubtitleColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCardCenter({
    required Widget icon,
    required String title,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: ShareMealPageController.optionIconToTitleGap.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inriaSerif(
              fontSize: ShareMealPageController.cardTitleFontSize.sp,
              fontWeight: FontWeight.w700,
              color: ShareMealPageController.cardTitleColor,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCardSubtitle(
    String subtitle,
    Color subtitleColor, {
    double? bottomPadding,
  }) {
    return Positioned(
      left: ShareMealPageController.optionCardPaddingH.w,
      right: ShareMealPageController.optionCardPaddingH.w,
      bottom: (bottomPadding ?? ShareMealPageController.optionSubtitleBottomPadding).h,
      child: Text(
        subtitle,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: ShareMealPageController.cardSubtitleFontSize.sp,
          fontWeight: FontWeight.w400,
          color: subtitleColor,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextCard(BuildContext context) {
    final radius = BorderRadius.circular(
      ShareMealPageController.optionCardRadius.r,
    );

    return SizedBox(
      width: double.infinity,
      height: ShareMealPageController.textCardHeight.h,
      child: Material(
        color: ShareMealPageController.textCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(
            color: ShareMealPageController.textCardBorder,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DescribeMealPage(),
              ),
            );
          },
          borderRadius: radius,
          splashColor: ShareMealPageController.backColor.withValues(alpha: 0.08),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ShareMealPageController.optionCardPaddingH.w,
                  vertical: ShareMealPageController.optionCardPaddingV.h,
                ),
                child: _buildOptionCardCenter(
                  icon: Image.asset(
                    ShareMealPageController.textIconAsset,
                    width: ShareMealPageController.optionIconSize.w,
                    height: ShareMealPageController.optionIconSize.w,
                    fit: BoxFit.contain,
                  ),
                  title: ShareMealPageController.textCardTitle,
                ),
              ),
              _buildOptionCardSubtitle(
                ShareMealPageController.textCardSubtitle,
                ShareMealPageController.textCardSubtitleColor,
                bottomPadding: ShareMealPageController.textCardSubtitleBottomPadding,
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
        '${ShareMealPageController.disclaimerLine1}\n'
        '${ShareMealPageController.disclaimerLine2}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: ShareMealPageController.disclaimerColor,
          height: 1.4,
        ),
      ),
    );
  }
}
