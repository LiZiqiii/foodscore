import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/food_score_insight_item.dart';
import '../models/food_score_result.dart';
import 'result_page_controller.dart';

const _tipsSectionTitle = 'TIPS FOR NEXT TIME';
const _emptyKeyInsightsFallback =
    'No insights are available for this meal yet based on the details provided.';
const _emptyTipsFallback =
    'No tips are available for this meal yet.';

/// AI 分析结果页（Score / Insight / Tips 横向滑动）。
class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.result,
    this.fromHistory = false,
  });

  final FoodScoreResult result;
  final bool fromHistory;

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
                  _TipsTab(
                    result: widget.result,
                    fromHistory: widget.fromHistory,
                  ),
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
                  style: TextStyle(
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
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _DimensionCard extends StatefulWidget {
  const _DimensionCard({
    required this.template,
    required this.dimension,
  });

  final ResultDimensionTemplate template;
  final ResultDimension dimension;

  @override
  State<_DimensionCard> createState() => _DimensionCardState();
}

class _DimensionCardState extends State<_DimensionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dimension = widget.dimension;
    final template = widget.template;
    final barColor = ResultPageController.scoreColor(dimension.score);
    final description = dimension.description.trim();
    final hasDetails = description.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(ResultPageController.cardRadius.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasDetails ? () => setState(() => _expanded = !_expanded) : null,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 9.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(template.emoji, style: TextStyle(fontSize: 20.sp)),
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
              SizedBox(height: 8.h),
              _FriendlySegmentedScoreBar(
                progress: dimension.progress,
                fillColor: barColor,
              ),
              if (_expanded && hasDetails) ...[
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: ResultPageController.cardBody,
                    height: 1.35,
                  ),
                ),
              ],
              if (hasDetails) ...[
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _expanded
                          ? ResultPageController.dimensionDetailsHide
                          : ResultPageController.dimensionDetailsShow,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: ResultPageController.scoreExplanationLinkColor,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18.sp,
                      color: ResultPageController.scoreExplanationLinkColor,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Five soft segments (20 pts each) — friendly meal-app style, not clinical.
class _FriendlySegmentedScoreBar extends StatelessWidget {
  const _FriendlySegmentedScoreBar({
    required this.progress,
    required this.fillColor,
  });

  final double progress;
  final Color fillColor;

  static const int _segmentCount = 5;
  static const Color _emptyColor = Color(0xFFE6EEE8);

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Row(
      children: List.generate(_segmentCount, (index) {
        final segmentStart = index / _segmentCount;
        final segmentEnd = (index + 1) / _segmentCount;
        var fillFactor = 0.0;
        if (clamped >= segmentEnd) {
          fillFactor = 1.0;
        } else if (clamped > segmentStart) {
          fillFactor = (clamped - segmentStart) * _segmentCount;
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < _segmentCount - 1 ? 5.w : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.r),
              child: SizedBox(
                height: 10.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: _emptyColor),
                    if (fillFactor > 0)
                      FractionallySizedBox(
                        widthFactor: fillFactor,
                        alignment: Alignment.centerLeft,
                        child: ColoredBox(color: fillColor),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
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
            ResultPageController.keyInsightsSectionTitle,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: ResultPageController.sectionTitle,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 12.h),
          if (result.keyInsights.isEmpty)
            _InsightCard(
              item: const FoodScoreInsightItem(
                title: 'Details are unclear',
                description: _emptyKeyInsightsFallback,
              ),
              iconIndex: 0,
            )
          else
            for (var i = 0; i < result.keyInsights.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              _InsightCard(
                item: result.keyInsights[i],
                iconIndex: i,
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
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${result.displayOverallScore}',
            style: TextStyle(
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
    required this.iconIndex,
  });

  final FoodScoreInsightItem item;
  final int iconIndex;

  static const _icons = [
    Icons.hub_outlined,
    Icons.auto_awesome_outlined,
    Icons.insights_outlined,
  ];

  static const _iconColors = [
    ResultPageController.scoreBarGood,
    ResultPageController.scoreBarGood,
    ResultPageController.scoreBarFair,
  ];

  @override
  Widget build(BuildContext context) {
    final index = iconIndex % _icons.length;
    final icon = _icons[index];
    final iconColor = _iconColors[index];

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
                  style: TextStyle(
                    fontSize: ResultPageController.insightCardTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                    color: ResultPageController.cardTitle,
                    height: 1.25,
                    letterSpacing: 0.1,
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
  const _TipsTab({
    required this.result,
    this.fromHistory = false,
  });

  final FoodScoreResult result;
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    final tips = result.mealTips.isNotEmpty
        ? result.mealTips
        : const [_emptyTipsFallback];

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
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _TipsHeroCard(body: tips[i]),
          ],
          SizedBox(height: 16.h),
          _TipsDisclaimerText(
            text: result.disclaimer.isNotEmpty
                ? result.disclaimer
                : ResultPageController.tipsDisclaimer,
          ),
          SizedBox(height: 18.h),
          Center(
            child: OutlinedButton(
              onPressed: () {
                if (fromHistory) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 47.h),
                side: BorderSide(
                  color: ResultPageController.gotItBorder,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                backgroundColor: Colors.white,
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
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 22.sp,
            color: ResultPageController.scoreBarGood,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              body,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: ResultPageController.cardTitle,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsDisclaimerText extends StatelessWidget {
  const _TipsDisclaimerText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: ResultPageController.scoreExplanationFooterColor,
          height: 1.45,
        ),
        children: [
          TextSpan(
            text: ResultPageController.rememberPrefix,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: ' $text'),
        ],
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
                    SizedBox(height: 16.h),
                    Text(
                      ResultPageController.scoreExplanationFooterDisclaimer,
                      style: TextStyle(
                        fontSize: 10.sp,
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
