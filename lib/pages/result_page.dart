import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/food_score_insight_item.dart';
import '../models/food_score_result.dart';
import 'result_page_controller.dart';

const _insightImprovedSectionTitle = 'WHAT COULD BE IMPROVED';
const _tipsSectionTitle = 'TIPS FOR NEXT TIME';
const _emptyDoesWellFallback =
    'No specific strengths were identified for this meal based on the details provided.';
const _emptyImprovedFallback =
    'No specific improvements were suggested for this meal.';
const _emptyTipsFallback =
    'No tips are available for this meal yet.';

/// AI 分析结果页（Score / Insight / Tips 横向滑动）。
class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.result,
  });

  final FoodScoreResult result;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResultPageController.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: ResultPageController.topExtraPadding.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResultPageController.horizontalPadding.w,
              ),
              child: _ResultTabBar(
                currentIndex: _currentPage,
                onTabTap: _onTabTap,
              ),
            ),
            SizedBox(height: 18.h),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _ScoreTab(result: widget.result),
                  _InsightTab(result: widget.result),
                  _TipsTab(result: widget.result),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTabBar extends StatelessWidget {
  const _ResultTabBar({
    required this.currentIndex,
    required this.onTabTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTabTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / 3;

        return Container(
          height: ResultPageController.tabBarHeight.h,
          decoration: BoxDecoration(
            color: ResultPageController.tabBarBg,
            borderRadius: BorderRadius.circular(
              ResultPageController.tabBarRadius.r,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                left: currentIndex * tabWidth,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  margin: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: ResultPageController.tabActiveBg,
                    borderRadius: BorderRadius.circular(
                      ResultPageController.tabBarRadius.r,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < ResultPageController.tabLabels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTabTap(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            ResultPageController.tabLabels[i],
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: currentIndex == i
                                  ? ResultPageController.tabActiveText
                                  : ResultPageController.tabInactiveText,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreTab extends StatelessWidget {
  const _ScoreTab({required this.result});

  final FoodScoreResult result;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResultPageController.horizontalPadding.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreHeroCard(result: result),
          SizedBox(height: 26.h),
          Text(
            ResultPageController.scoreBreakdownTitle,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: ResultPageController.sectionTitle,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 14.h),
          for (var i = 0; i < result.scoreDimensions.length; i++) ...[
            if (i > 0) SizedBox(height: 12.h),
            _DimensionCard(
              template: ResultPageController.templateAt(i),
              dimension: result.scoreDimensions[i],
            ),
          ],
          SizedBox(height: 18.h),
          Center(child: _ScoreExplanationLink()),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _ScoreHeroCard extends StatelessWidget {
  const _ScoreHeroCard({required this.result});

  final FoodScoreResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: ResultPageController.heroGreenSolid.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(ResultPageController.heroRadius.r),
      ),
      child: Column(
        children: [
          Text(
            ResultPageController.foodQualityScoreLabel,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: ResultPageController.heroLabel,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 18.h),
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ResultPageController.scoreCircle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${result.displayOverallScore}',
                  style: GoogleFonts.inriaSerif(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ResultPageController.outOf100Label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            result.mealName,
            textAlign: TextAlign.center,
            style: GoogleFonts.inriaSerif(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DimensionCard extends StatelessWidget {
  const _DimensionCard({
    required this.template,
    required this.dimension,
  });

  final ResultDimensionTemplate template;
  final ResultDimension dimension;

  @override
  Widget build(BuildContext context) {
    final barColor = ResultPageController.scoreColor(dimension.score);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResultPageController.cardRadius.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(template.emoji, style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  template.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ResultPageController.cardTitle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: LinearProgressIndicator(
              value: dimension.progress,
              minHeight: 9.h,
              backgroundColor: const Color(0xFFD9D9D9),
              color: barColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            dimension.description,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: ResultPageController.cardBody,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTab extends StatelessWidget {
  const _InsightTab({required this.result});

  final FoodScoreResult result;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResultPageController.horizontalPadding.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightHeroCard(result: result),
          SizedBox(height: 18.h),
          Text(
            ResultPageController.doesWellSectionTitle,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: ResultPageController.sectionTitle,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 12.h),
          if (result.whatThisMealDoesWell.isEmpty)
            _InsightCard(
              item: const FoodScoreInsightItem(
                title: 'Details are unclear',
                description: _emptyDoesWellFallback,
              ),
              isPositive: true,
            )
          else
            for (var i = 0; i < result.whatThisMealDoesWell.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              _InsightCard(
                item: result.whatThisMealDoesWell[i],
                isPositive: true,
              ),
            ],
          SizedBox(height: 18.h),
          Text(
            _insightImprovedSectionTitle,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: ResultPageController.sectionTitle,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 12.h),
          if (result.whatCouldBeImproved.isEmpty)
            _InsightCard(
              item: const FoodScoreInsightItem(
                title: 'Small improvement',
                description: _emptyImprovedFallback,
              ),
              isPositive: false,
            )
          else
            for (var i = 0; i < result.whatCouldBeImproved.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              _InsightCard(
                item: result.whatCouldBeImproved[i],
                isPositive: false,
              ),
            ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _InsightHeroCard extends StatelessWidget {
  const _InsightHeroCard({required this.result});

  final FoodScoreResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: ResultPageController.heroGreenSolid.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(ResultPageController.heroRadius.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Image.asset(
              ResultPageController.insightMealImageAsset,
              width: 42.w,
              height: 42.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ResultPageController.analysedMealLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: ResultPageController.heroLabel,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  result.mealName,
                  style: GoogleFonts.inriaSerif(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${result.displayOverallScore}',
            style: GoogleFonts.inriaSerif(
              fontSize: 34.sp,
              fontWeight: FontWeight.w700,
              color: ResultPageController.scoreAccent,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.item,
    required this.isPositive,
  });

  final FoodScoreInsightItem item;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final icon = isPositive
        ? Icons.check_circle_rounded
        : Icons.lightbulb_outline_rounded;
    final iconColor = isPositive
        ? ResultPageController.scoreBarGood
        : ResultPageController.scoreBarFair;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResultPageController.insightCardRadius.r,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22.sp, color: iconColor),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inriaSerif(
                    fontSize: ResultPageController.insightCardTitleFontSize.sp,
                    fontWeight: FontWeight.w700,
                    color: ResultPageController.cardTitle,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: ResultPageController.cardBody,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsTab extends StatelessWidget {
  const _TipsTab({required this.result});

  final FoodScoreResult result;

  @override
  Widget build(BuildContext context) {
    final tips = result.tips.trim().isNotEmpty
        ? result.tips.trim()
        : _emptyTipsFallback;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResultPageController.horizontalPadding.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tipsSectionTitle,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: ResultPageController.sectionTitle,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 12.h),
          _TipsHeroCard(body: tips),
          SizedBox(height: 20.h),
          _DisclaimerBox(
            prefix: ResultPageController.rememberPrefix,
            text: result.disclaimer.isNotEmpty
                ? result.disclaimer
                : ResultPageController.tipsDisclaimer,
          ),
          SizedBox(height: 20.h),
          Center(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 47.h),
                side: BorderSide(
                  color: ResultPageController.gotItBorder,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.54),
                foregroundColor: ResultPageController.gotItText,
              ),
              child: Text(
                ResultPageController.gotItLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _TipsHeroCard extends StatelessWidget {
  const _TipsHeroCard({
    required this.body,
  });

  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: ResultPageController.heroGreenSolid.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(ResultPageController.heroRadius.r),
      ),
      child: Text(
        body,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.95),
          height: 1.45,
        ),
      ),
    );
  }
}

class _DisclaimerBox extends StatelessWidget {
  const _DisclaimerBox({
    required this.prefix,
    required this.text,
  });

  final String prefix;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: ResultPageController.disclaimerBg,
        borderRadius: BorderRadius.circular(ResultPageController.cardRadius.r),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: ResultPageController.disclaimerText,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: '$prefix ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}

class _ScoreExplanationLink extends StatelessWidget {
  const _ScoreExplanationLink();

  static void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) => const _ScoreExplanationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _openSheet(context),
      style: TextButton.styleFrom(
        foregroundColor: ResultPageController.scoreExplanationLinkColor,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14.sp,
            color: ResultPageController.scoreExplanationLinkColor,
          ),
          SizedBox(width: 5.w),
          Text(
            ResultPageController.scoreExplanationLinkLabel,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: ResultPageController.scoreExplanationLinkColor
                  .withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreExplanationSheet extends StatelessWidget {
  const _ScoreExplanationSheet();

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height *
        ResultPageController.scoreExplanationSheetHeightFactor;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: ResultPageController.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResultPageController.heroRadius.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 14.h, 12.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ResultPageController.scoreExplanationTitle,
                      style: GoogleFonts.inriaSerif(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w700,
                        color: ResultPageController.cardTitle,
                        height: 1.25,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22.sp,
                      color: ResultPageController.cardBody,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ResultPageController.scoreExplanationSubtitle,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: ResultPageController.scoreExplanationSubtitleColor,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      ResultPageController.scoreExplanationIntro,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: ResultPageController.cardBody,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    for (final item
                        in ResultPageController.scoreExplanationDimensions) ...[
                      _ScoreExplanationDimensionCard(item: item),
                      SizedBox(height: 12.h),
                    ],
                    SizedBox(height: 8.h),
                    Text(
                      ResultPageController.scoreExplanationSupportiveNote,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: ResultPageController.cardBody,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      ResultPageController.scoreExplanationFooterDisclaimer,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: ResultPageController.scoreExplanationFooterColor,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 8.h, 22.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: ResultPageController.heroGreenSolid,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    ResultPageController.gotItLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
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

class _ScoreExplanationDimensionCard extends StatelessWidget {
  const _ScoreExplanationDimensionCard({required this.item});

  final ScoreExplanationDimension item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResultPageController.insightCardRadius.r,
        ),
        border: Border.all(
          color: ResultPageController.heroGreenSolid.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ResultPageController.cardTitle,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.explanation,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: ResultPageController.cardBody,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
