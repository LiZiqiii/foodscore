import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import '../models/weekly_reflection_meal.dart';
import '../config/page_layout.dart';
import '../services/weekly_reflection_store.dart';
import '../widgets/page_back_button.dart';
import 'share_meal_page.dart';
import 'weekly_reflection_controller.dart';

/// Weekly Reflection 页：无数据时展示 empty state。
class WeeklyReflectionPage extends StatefulWidget {
  const WeeklyReflectionPage({super.key});

  @override
  State<WeeklyReflectionPage> createState() => _WeeklyReflectionPageState();
}

class _WeeklyReflectionPageState extends State<WeeklyReflectionPage> {
  late List<WeeklyReflectionMeal> _meals;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() {
    _meals = WeeklyReflectionStore.instance.meals;
  }

  void _openAnalyseFlow() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ShareMealPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WeeklyReflectionController.backgroundColor,
      body: SafeArea(
        child: _meals.isEmpty ? _buildEmptyState(context) : _buildContent(context),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return const PageBackButton();
  }

  Widget _buildPageTitle() {
    return Text(
      WeeklyReflectionController.title,
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: WeeklyReflectionController.titleColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildAnalyseButton() {
    final borderRadius = BorderRadius.circular(
      PageLayout.primaryButtonRadius.r,
    );

    return Material(
      color: WeeklyReflectionController.ctaColor,
      elevation: 2.5,
      shadowColor: WeeklyReflectionController.ctaColor.withValues(alpha: 0.28),
      borderRadius: borderRadius,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: _openAnalyseFlow,
        borderRadius: borderRadius,
        splashColor: Colors.white.withValues(alpha: 0.18),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: SizedBox(
          width: double.infinity,
          height: WeeklyReflectionController.ctaHeight.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                WeeklyReflectionController.emptyCtaLabel,
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

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: WeeklyReflectionController.horizontalPadding.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: PageLayout.topExtraPadding.h),
          _buildBackButton(context),
          SizedBox(height: PageLayout.backToTitleGap.h),
          _buildPageTitle(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 48.sp,
                  color: WeeklyReflectionController.backColor.withValues(
                    alpha: 0.35,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  WeeklyReflectionController.emptyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: WeeklyReflectionController.emptyTitleColor,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    WeeklyReflectionController.emptySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: WeeklyReflectionController.emptySubtitleColor,
                      height: 1.45,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                _buildAnalyseButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: WeeklyReflectionController.horizontalPadding.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: PageLayout.topExtraPadding.h),
            _buildBackButton(context),
            SizedBox(height: PageLayout.backToTitleGap.h),
            _buildPageTitle(),
            SizedBox(height: 24.h),
            Text(
              WeeklyReflectionController.savedMealsHeading,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: WeeklyReflectionController.titleColor,
              ),
            ),
            SizedBox(height: 12.h),
            for (final meal in _meals) ...[
              _buildMealCard(meal),
              SizedBox(height: 10.h),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(WeeklyReflectionMeal meal) {
    final dateLabel = _formatSavedDate(meal.savedAt);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: WeeklyReflectionController.cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: WeeklyReflectionController.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                meal.isPhoto ? Icons.photo_outlined : Icons.edit_note_outlined,
                size: 16.sp,
                color: WeeklyReflectionController.backColor,
              ),
              SizedBox(width: 6.w),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: WeeklyReflectionController.cardMetaColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            meal.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: WeeklyReflectionController.titleColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSavedDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}
