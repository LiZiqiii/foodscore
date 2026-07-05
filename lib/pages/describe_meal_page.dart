import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import 'describe_meal_page_controller.dart';
import 'meal_analysis_loading_page.dart';

/// 文字描述餐食页面。
class DescribeMealPage extends StatefulWidget {
  const DescribeMealPage({super.key});

  @override
  State<DescribeMealPage> createState() => _DescribeMealPageState();
}

class _DescribeMealPageState extends State<DescribeMealPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasInput => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DescribeMealPageController.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = _buildContent(
              context,
              fillHeight: constraints.maxHeight >= 700,
            );
            if (constraints.maxHeight < 700) {
              return SingleChildScrollView(child: content);
            }
            return SizedBox(
              height: constraints.maxHeight,
              child: content,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required bool fillHeight}) {
    final bottomSpacer = fillHeight
        ? const Spacer()
        : SizedBox(height: DescribeMealPageController.disclaimerBottomPadding.h);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DescribeMealPageController.horizontalPadding.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: DescribeMealPageController.topExtraPadding.h),
          _buildBackButton(context),
          SizedBox(height: DescribeMealPageController.backToTitleGap.h),
          _buildTitleSection(),
          SizedBox(height: DescribeMealPageController.subtitleToInputGap.h),
          _buildInputField(),
          SizedBox(height: DescribeMealPageController.inputToTipsGap.h),
          _buildTipsSection(),
          SizedBox(height: DescribeMealPageController.tipsToCtaGap.h),
          _buildCtaButton(context),
          SizedBox(height: DescribeMealPageController.ctaToDisclaimerGap.h),
          _buildDisclaimer(),
          bottomSpacer,
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Text(
          DescribeMealPageController.backLabel,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: DescribeMealPageController.backColor,
            letterSpacing: 0.2,
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
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: DescribeMealPageController.titleColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: DescribeMealPageController.titleToSubtitleGap.h),
        Text(
          DescribeMealPageController.subtitle,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: DescribeMealPageController.subtitleFontSize.sp,
            fontWeight: FontWeight.w400,
            color: DescribeMealPageController.subtitleColor,
            height: 20 / 14,
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
      child: TextField(
        controller: _controller,
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
    );
  }

  Widget _buildTipsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 10.w,
          runSpacing: DescribeMealPageController.tipRowGap.h,
          children: [
            for (var i = 0; i < DescribeMealPageController.tips.length; i++)
              _buildTipChip(
                DescribeMealPageController.tips[i],
                maxWidth: constraints.maxWidth,
                isLast: i == DescribeMealPageController.tips.length - 1,
              ),
          ],
        );
      },
    );
  }

  Widget _buildTipChip(
    String label, {
    required double maxWidth,
    bool isLast = false,
  }) {
    final textStyle = TextStyle(
      fontSize: DescribeMealPageController.tipFontSize.sp,
      fontWeight: FontWeight.w400,
      color: DescribeMealPageController.tipTextColor,
      height: 1.1,
    );

    Widget labelText = Text(
      label,
      maxLines: 1,
      softWrap: false,
      overflow: isLast ? TextOverflow.visible : TextOverflow.ellipsis,
      style: textStyle,
    );

    if (isLast) {
      labelText = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: labelText,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        width: isLast ? maxWidth : null,
        height: DescribeMealPageController.tipChipHeight.h,
        padding: EdgeInsets.symmetric(
          horizontal: DescribeMealPageController.tipChipPaddingH.w,
        ),
        decoration: BoxDecoration(
          color: DescribeMealPageController.tipBg,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          mainAxisSize: isLast ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Text(
              '💡',
              style: TextStyle(
                fontSize: DescribeMealPageController.tipIconSize.sp,
                height: 1,
              ),
            ),
            SizedBox(width: DescribeMealPageController.tipIconGap.w),
            if (isLast) Expanded(child: labelText) else Flexible(child: labelText),
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
      DescribeMealPageController.ctaRadius.r,
    );

    return Center(
      child: Material(
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
            width: DescribeMealPageController.ctaMaxWidth.w,
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
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Center(
      child: Text(
        '${DescribeMealPageController.disclaimerLine1}\n'
        '${DescribeMealPageController.disclaimerLine2}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: DescribeMealPageController.disclaimerColor,
          height: 1.4,
        ),
      ),
    );
  }
}
