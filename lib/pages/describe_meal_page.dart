import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'describe_meal_page_controller.dart';
import '../config/page_layout.dart';
import '../widgets/page_back_button.dart';
import 'meal_analysis_loading_page.dart';

/// Describe meal page
class DescribeMealPage extends StatefulWidget {
  const DescribeMealPage({super.key});
  @override
  State<DescribeMealPage> createState() => _DescribeMealPageState();
}
class _DescribeMealPageState extends State<DescribeMealPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _inputScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }
  @override
  void dispose() {
    _controller.dispose();
    _inputScrollController.dispose();
    super.dispose();
  }
  bool get _hasInput => _controller.text.trim().isNotEmpty;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DescribeMealPageController.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DescribeMealPageController.horizontalPadding.w,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: PageLayout.topExtraPadding.h),
                const PageBackButton(),
                SizedBox(height: PageLayout.backToTitleGap.h),
                _buildTitleSection(),
                SizedBox(height: DescribeMealPageController.subtitleToInputGap.h),
                _buildInputField(),
                SizedBox(height: DescribeMealPageController.inputToTipsGap.h),
                _buildTipsSection(),
                SizedBox(height: DescribeMealPageController.tipsToCtaGap.h),
                _buildCtaButton(context),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DescribeMealPageController.title,
          style: TextStyle(
            fontSize: MealFlowPageStyle.titleFontSize.sp,
            fontWeight: FontWeight.w600,
            color: MealFlowPageStyle.titleColor,
            height: MealFlowPageStyle.titleLineHeight,
          ),
        ),
        SizedBox(height: MealFlowPageStyle.titleToSubtitleGap.h),
        Text(
          DescribeMealPageController.subtitle,
          style: TextStyle(
            fontSize: MealFlowPageStyle.subtitleFontSize.sp,
            fontWeight: FontWeight.w400,
            color: MealFlowPageStyle.subtitleColor,
            height: MealFlowPageStyle.subtitleLineHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    final radius = BorderRadius.only(
      topLeft: Radius.circular(DescribeMealPageController.inputRadiusTL.r),
      topRight: Radius.circular(DescribeMealPageController.inputRadiusTR.r),
      bottomLeft: Radius.circular(DescribeMealPageController.inputRadiusBL.r),
      bottomRight: Radius.circular(DescribeMealPageController.inputRadiusBR.r),
    );

    return SizedBox(
      width: double.infinity,
      height: DescribeMealPageController.inputHeight.h,
      child: Scrollbar(
        controller: _inputScrollController,
        thumbVisibility: true,
        child: TextField(
          controller: _controller,
          scrollController: _inputScrollController,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: DescribeMealPageController.inputFontSize.sp,
          fontWeight: FontWeight.w400,
          color: DescribeMealPageController.inputTextColor,
          height: DescribeMealPageController.inputLineHeight,
        ),
        decoration: InputDecoration(
          hintText: DescribeMealPageController.inputHint,
          hintStyle: TextStyle(
            fontSize: DescribeMealPageController.inputFontSize.sp,
            fontWeight: FontWeight.w400,
            color: DescribeMealPageController.inputHintColor,
            height: DescribeMealPageController.inputLineHeight,
          ),
          filled: true,
          fillColor: DescribeMealPageController.inputBg,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DescribeMealPageController.inputPaddingH.w,
            vertical: DescribeMealPageController.inputPaddingV.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(
              color: DescribeMealPageController.inputBorderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: DescribeMealPageController.backColor.withValues(
                alpha: 0.35,
              ),
              width: 1,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(
              color: DescribeMealPageController.inputBorderColor,
              width: 1,
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = DescribeMealPageController.tips;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 10.w;
        final columnWidth = (constraints.maxWidth - gap) / 2;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: columnWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTipChip(
                      tips[0],
                      indent: DescribeMealPageController.tipLeftColumnInset.w,
                    ),
                  ),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: columnWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTipChip(
                      tips[1],
                      indent: DescribeMealPageController.tipRightColumnInset.w,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DescribeMealPageController.tipRowGap.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: columnWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTipChip(
                      tips[2],
                      indent: DescribeMealPageController.tipLeftColumnInset.w,
                    ),
                  ),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: columnWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTipChip(
                      tips[3],
                      indent: DescribeMealPageController.tipRightColumnInset.w,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipChip(String label, {double indent = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: DescribeMealPageController.tipChipPaddingH.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: DescribeMealPageController.tipBg,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💡',
              style: TextStyle(
                fontSize: DescribeMealPageController.tipIconSize.sp,
                height: 1,
              ),
            ),
            SizedBox(width: DescribeMealPageController.tipIconGap.w),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: DescribeMealPageController.tipFontSize.sp,
                fontWeight: FontWeight.w400,
                color: DescribeMealPageController.tipTextColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    final enabled = _hasInput;
    final bgColor = enabled
        ? DescribeMealPageController.ctaEnabledBg
        : DescribeMealPageController.ctaDisabledBg;
    final textColor = enabled
        ? Colors.white
        : DescribeMealPageController.ctaDisabledText;
    final borderRadius = BorderRadius.circular(
      PageLayout.primaryButtonRadius.r,
    );

    return Material(
      color: bgColor,
      elevation: enabled ? 2.5 : 0,
      shadowColor: enabled
          ? DescribeMealPageController.ctaEnabledBg.withValues(alpha: 0.28)
          : Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: enabled
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MealAnalysisLoadingPage(
                      mealText: _controller.text.trim(),
                    ),
                  ),
                );
              }
            : null,
        borderRadius: borderRadius,
        splashColor: enabled ? Colors.white.withValues(alpha: 0.18) : null,
        highlightColor: enabled ? Colors.white.withValues(alpha: 0.08) : null,
        child: SizedBox(
          width: double.infinity,
          height: DescribeMealPageController.ctaHeight.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DescribeMealPageController.ctaLabel,
                  style: TextStyle(
                    fontSize: DescribeMealPageController.ctaFontSize.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.15,
                  ),
                ),
                SizedBox(width: DescribeMealPageController.ctaIconGap.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: DescribeMealPageController.ctaIconSize.sp,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
    );
  }
}
