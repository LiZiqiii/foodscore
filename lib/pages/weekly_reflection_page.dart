import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../config/page_layout.dart';
import '../models/user_profile.dart';
import '../models/weekly_reflection_meal.dart';
import '../services/meal_record_service_factory.dart';
import '../services/user_profile_service_factory.dart';
import '../services/weekly_reflection_format.dart';
import '../services/weekly_reflection_store.dart';
import '../models/weekly_reflection_summary.dart';
import '../services/weekly_reflection_summary_builder.dart';
import '../services/weekly_reflection_summary_cache.dart';
import '../services/weekly_reflection_summary_service_factory.dart';
import '../widgets/app_spot_illustration.dart';
import '../widgets/page_back_button.dart';
import 'share_meal_page.dart';
import 'weekly_reflection_controller.dart';

/// Weekly Reflection 页。
class WeeklyReflectionPage extends StatefulWidget {
  const WeeklyReflectionPage({super.key});

  @override
  State<WeeklyReflectionPage> createState() => _WeeklyReflectionPageState();
}

class _WeeklyReflectionPageState extends State<WeeklyReflectionPage> {
  String? _loadedSummaryKey;
  WeeklyReflectionSummary? _summary;
  UserProfile? _coachingProfile;
  bool _summaryLoading = false;
  bool _mealsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadCoachingProfile() async {
    if (AppConfig.useMockResult) {
      _coachingProfile = null;
      return;
    }

    try {
      _coachingProfile =
          await createUserProfileService().loadProfile(currentUserId);
    } catch (error) {
      debugPrint('Failed to load coaching profile for weekly summary: $error');
      _coachingProfile = null;
    }
  }

  Future<void> _loadPageData() async {
    setState(() {
      _mealsLoading = true;
    });

    await _loadCoachingProfile();

    if (AppConfig.useMockResult) {
      if (!mounted) {
        return;
      }
      setState(() => _mealsLoading = false);
      _scheduleSummaryRefresh();
      return;
    }

    final service = createMealRecordService();
    if (service == null) {
      if (!mounted) {
        return;
      }
      setState(() => _mealsLoading = false);
      _scheduleSummaryRefresh();
      return;
    }

    try {
      final meals = await service.fetchRecentMealRecords(
        userId: currentUserId,
        days: AppConfig.weeklyReflectionDays,
        limit: 30,
      );
      WeeklyReflectionStore.instance.replaceMealsFromBackend(meals);
    } catch (error) {
      debugPrint('Failed to load meal records from backend: $error');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _mealsLoading = false;
    });
    _scheduleSummaryRefresh();
  }

  String _summaryContextKey(List<WeeklyReflectionMeal> meals) {
    return WeeklyReflectionSummaryCache.contextKey(
      userId: currentUserId,
      meals: meals,
      profile: _coachingProfile,
    );
  }

  void _scheduleSummaryRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final meals = WeeklyReflectionStore.instance.mealsWithinLast7Days;
      _refreshSummary(meals);
    });
  }

  Future<void> _refreshSummary(List<WeeklyReflectionMeal> meals) async {
    if (meals.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = null;
        _summaryLoading = false;
        _loadedSummaryKey = null;
      });
      return;
    }

    final contextKey = _summaryContextKey(meals);
    if (contextKey == _loadedSummaryKey && _summary != null) {
      return;
    }

    final cached = WeeklyReflectionSummaryCache.get(
      userId: currentUserId,
      contextKey: contextKey,
    );
    if (cached != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _summary = cached;
        _loadedSummaryKey = contextKey;
        _summaryLoading = false;
      });
      return;
    }

    setState(() {
      _summaryLoading = true;
    });

    try {
      final summary = await createWeeklyReflectionSummaryService().buildSummary(
        meals,
        userId: currentUserId,
      );
      if (!mounted) {
        return;
      }

      final currentMeals = WeeklyReflectionStore.instance.mealsWithinLast7Days;
      final currentKey = _summaryContextKey(currentMeals);
      if (currentKey != contextKey) {
        _scheduleSummaryRefresh();
        return;
      }

      WeeklyReflectionSummaryCache.save(
        userId: currentUserId,
        contextKey: contextKey,
        summary: summary,
      );
      setState(() {
        _summary = summary;
        _loadedSummaryKey = contextKey;
      });
    } catch (error) {
      debugPrint('Weekly summary failed, using local fallback: $error');
      if (!mounted) {
        return;
      }

      final currentMeals = WeeklyReflectionStore.instance.mealsWithinLast7Days;
      final currentKey = _summaryContextKey(currentMeals);
      if (currentKey != contextKey) {
        _scheduleSummaryRefresh();
        return;
      }

      final fallback = WeeklyReflectionSummaryBuilder.build(meals);
      WeeklyReflectionSummaryCache.save(
        userId: currentUserId,
        contextKey: contextKey,
        summary: fallback,
      );
      setState(() {
        _summary = fallback;
        _loadedSummaryKey = contextKey;
      });
    } finally {
      if (mounted) {
        setState(() {
          _summaryLoading = false;
        });
      }
    }
  }

  Future<void> _openAnalyseFlow() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ShareMealPage(),
      ),
    );
    if (mounted) {
      await _loadPageData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = WeeklyReflectionStore.instance.mealsWithinLast7Days;
    final contextKey = meals.isEmpty ? null : _summaryContextKey(meals);
    if (contextKey != null &&
        contextKey != _loadedSummaryKey &&
        !_summaryLoading &&
        !_mealsLoading) {
      _scheduleSummaryRefresh();
    }

    return Scaffold(
      backgroundColor: WeeklyReflectionController.backgroundColor,
      body: SafeArea(
        child: _mealsLoading
            ? const Center(child: CircularProgressIndicator())
            : meals.isEmpty
                ? _buildEmptyState(context)
                : _buildContent(context, meals),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return const PageBackButton();
  }

  Widget _buildPageHeader() {
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
          _buildPageHeader(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSpotIllustration(
                  kind: AppSpotIllustrationKind.weeklyReflectionEmpty,
                  size: 120,
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

  Widget _buildContent(
    BuildContext context,
    List<WeeklyReflectionMeal> meals,
  ) {
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
            _buildPageHeader(),
            SizedBox(height: 28.h),
            _buildWeeklySummarySection(),
            SizedBox(height: 36.h),
            _buildSectionTitle(WeeklyReflectionController.recentMealsTitle),
            SizedBox(height: 14.h),
            for (var i = 0; i < meals.length; i++) ...[
              if (i > 0) SizedBox(height: 12.h),
              _buildMealCard(meals[i]),
            ],
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(WeeklyReflectionController.weeklySummaryTitle),
        SizedBox(height: 12.h),
        if (_summaryLoading)
          _buildSummaryLoading()
        else if (_summary != null) _buildSummaryCard(_summary!),
      ],
    );
  }

  Widget _buildSummaryCard(WeeklyReflectionSummary summary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: WeeklyReflectionController.summaryCardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: WeeklyReflectionController.cardBorder.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBlock(
            title: WeeklyReflectionController.goodPatternsTitle,
            items: summary.goodPatterns,
          ),
          SizedBox(height: 10.h),
          _buildSummaryBlock(
            title: WeeklyReflectionController.smallFocusTitle,
            items: summary.smallFocus,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLoading() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: WeeklyReflectionController.summaryCardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: WeeklyReflectionController.cardBorder.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: WeeklyReflectionController.backColor.withValues(
                alpha: 0.75,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            WeeklyReflectionController.summaryLoadingLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: WeeklyReflectionController.subtitleColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: WeeklyReflectionController.sectionTitleColor,
        letterSpacing: 0.25,
      ),
    );
  }

  Widget _buildMealCard(WeeklyReflectionMeal meal) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: WeeklyReflectionController.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: WeeklyReflectionController.cardBorder),
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
            meal.mealName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inriaSerif(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: WeeklyReflectionController.titleColor,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            WeeklyReflectionFormat.dayAndTime(meal.savedAt),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: WeeklyReflectionController.cardMetaColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              for (final tag in meal.tags) _buildTagChip(tag),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            meal.status,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: WeeklyReflectionController.statusColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: WeeklyReflectionController.tagBg,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: WeeklyReflectionController.tagText,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildSummaryBlock({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: WeeklyReflectionController.backColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6.h),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1.h, right: 6.w),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: WeeklyReflectionController.backColor.withValues(
                      alpha: 0.55,
                    ),
                    height: 1.35,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: WeeklyReflectionController.titleColor,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
