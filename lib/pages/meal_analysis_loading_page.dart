import 'dart:math' as math;

import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';
import '../models/food_score_result.dart';
import '../services/food_score_service.dart';
import '../services/food_score_service_factory.dart';
import '../services/meal_record_service.dart';
import '../services/meal_record_service_factory.dart';
import '../services/mock_food_score_service.dart';
import '../services/weekly_reflection_store.dart';
import 'meal_analysis_loading_controller.dart';
import 'result_page.dart';

///  Loading page
class MealAnalysisLoadingPage extends StatefulWidget {
  const MealAnalysisLoadingPage({
    super.key,
    this.mealText,
    this.imagePath,
    this.imageFile,
    this.description,
    this.saveForReflectionOnly = false,
  });

  /// meal text
  final String? mealText;

  /// image path
  final String? imagePath;

  /// image file
  final XFile? imageFile;

  /// description
  final String? description;

  /// save for reflection only
  final bool saveForReflectionOnly;
  @override
  State<MealAnalysisLoadingPage> createState() =>
      _MealAnalysisLoadingPageState();
}
class _MealAnalysisLoadingPageState extends State<MealAnalysisLoadingPage>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isAnalysing = true;
  String? _errorMessage;
  bool _analysisUsedMock = AppConfig.useMockResult;
  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _runAnalysis();
  }
  FoodScoreService _createService() => createFoodScoreService();
  Future<void> _runAnalysis({FoodScoreService? serviceOverride}) async {
    setState(() {
      _isAnalysing = true;
      _errorMessage = null;
    });
    if (!_spinController.isAnimating) {
      _spinController.repeat();
    }
    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
    final service = serviceOverride ?? _createService();
    _analysisUsedMock =
        serviceOverride is MockFoodScoreService || AppConfig.useMockResult;
    try {
      final FoodScoreResult result;
      if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
        List<int>? imageBytes;
        String? imageFileName;
        if (widget.imageFile != null) {
          imageBytes = await widget.imageFile!.readAsBytes();
          imageFileName = widget.imageFile!.name;
        }
        result = await service.analyseMealFromImage(
          imagePath: widget.imagePath!,
          imageBytes: imageBytes,
          imageFileName: imageFileName,
          description: widget.description,
          userId: currentUserId,
        );
      } else {
        result = await service.analyseMealFromText(
          widget.mealText ?? '',
          userId: currentUserId,
        );
      }

      if (!mounted) {
        return;
      }
      await _persistMealRecordIfNeeded(result);
      if (!mounted) {
        return;
      }
      if (widget.saveForReflectionOnly) {
        _finishReflectionSave(result);
      } else {
        _goToResultPage(result);
      }
    } on FoodScoreServiceException catch (error) {
      _showError(error.message);
    } catch (error, stackTrace) {
      debugPrint('Meal analysis failed: $error\n$stackTrace');
      final detail = error.toString();
      if (detail.isNotEmpty && detail.length < 280) {
        _showError(detail);
      } else {
        _showError(MealAnalysisLoadingController.errorFallbackMessage);
      }
    }
  }
  void _showError(String message) {
    if (!mounted) {
      return;
    }
    _spinController.stop();
    _pulseController.stop();
    setState(() {
      _isAnalysing = false;
      _errorMessage = message;
    });
  }
  Future<void> _useMockResult() {
    return _runAnalysis(
      serviceOverride: MockFoodScoreService(),
    );
  }
  Future<void> _persistMealRecordIfNeeded(FoodScoreResult result) async {
    if (_analysisUsedMock) {
      return;
    }
    final service = createMealRecordService();
    if (service == null) {
      return;
    }
    final mealText = _originalMealTextForSave();
    if (mealText.isEmpty) {
      return;
    }
    try {
      await service.saveMealRecord(
        userId: currentUserId,
        mealText: mealText,
        result: result,
      );
    } on MealRecordServiceException catch (error) {
      debugPrint('Meal record save failed: ${error.message}');
    } catch (error) {
      debugPrint('Meal record save failed: $error');
    }
  }
  String _originalMealTextForSave() {
    final mealText = widget.mealText?.trim();
    if (mealText != null && mealText.isNotEmpty) {
      return mealText;
    }
    final description = widget.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return 'Meal photo';
    }
    return '';
  }
  void _goToResultPage(FoodScoreResult result) {
    if (!mounted) {
      return;
    }
    final isPhoto =
        widget.imagePath != null && widget.imagePath!.isNotEmpty;
    WeeklyReflectionStore.instance.addFromInstantFeedback(
      result,
      isPhoto: isPhoto,
      mealText: _originalMealTextForSave(),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultPage(result: result),
      ),
    );
  }
  void _finishReflectionSave(FoodScoreResult result) {
    if (!mounted) {
      return;
    }
    final isPhoto =
        widget.imagePath != null && widget.imagePath!.isNotEmpty;
    WeeklyReflectionStore.instance.addFromReflectionSave(
      result,
      isPhoto: isPhoto,
      mealText: _originalMealTextForSave(),
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(
        content: Text(MealAnalysisLoadingController.reflectionSavedMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  String get _loadingTitle {
    if (!_isAnalysing) {
      return MealAnalysisLoadingController.errorTitle;
    }
    if (widget.saveForReflectionOnly) {
      return MealAnalysisLoadingController.reflectionSaveTitle;
    }
    return MealAnalysisLoadingController.title;
  }
  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoadingBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MealAnalysisLoadingController.horizontalPadding.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLoadingCard(),
                    if (!_isAnalysing && _errorMessage != null) ...[
                      SizedBox(height: 16.h),
                      _buildErrorPanel(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: MealAnalysisLoadingController.cardPaddingH.w,
        vertical: MealAnalysisLoadingController.cardPaddingV.h,
      ),
      decoration: BoxDecoration(
        color: MealAnalysisLoadingController.cardColor,
        borderRadius: BorderRadius.circular(
          MealAnalysisLoadingController.cardRadius.r,
        ),
        boxShadow: [
          BoxShadow(
            color: MealAnalysisLoadingController.glowColor.withValues(
              alpha: 0.07,
            ),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBrandedLoader(),
          SizedBox(height: 22.h),
          Text(
            _loadingTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MealAnalysisLoadingController.titleFontSize.sp,
              fontWeight: FontWeight.w600,
              color: MealAnalysisLoadingController.titleColor,
              height: 1.3,
            ),
          ),
          if (!_isAnalysing && _errorMessage != null) ...[
            SizedBox(height: 10.h),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MealAnalysisLoadingController.subtitleFontSize.sp,
                fontWeight: FontWeight.w400,
                color: MealAnalysisLoadingController.errorMessageColor,
                height: 1.45,
              ),
            ),
          ],
          if (_isAnalysing) ...[
            SizedBox(height: 8.h),
            Text(
              MealAnalysisLoadingController.hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MealAnalysisLoadingController.hintFontSize.sp,
                fontWeight: FontWeight.w400,
                color: MealAnalysisLoadingController.hintColor,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBrandedLoader() {
    final ringSize = MealAnalysisLoadingController.ringSize.w;
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: AnimatedBuilder(
        animation: _spinController,
        builder: (context, child) {
          return CustomPaint(
            painter: _GreenRingPainter(
              progress: _isAnalysing ? _spinController.value : 0,
              trackColor: MealAnalysisLoadingController.ringTrackColor,
              activeColor: MealAnalysisLoadingController.ringActiveColor,
              strokeWidth: MealAnalysisLoadingController.ringStroke,
            ),
            child: child,
          );
        },
        child: Center(
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Icon(
              _isAnalysing ? Icons.eco_outlined : Icons.error_outline_rounded,
              size: MealAnalysisLoadingController.iconSize.sp,
              color: MealAnalysisLoadingController.iconColor,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildErrorPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _runAnalysis(),
            style: OutlinedButton.styleFrom(
              foregroundColor: MealAnalysisLoadingController.errorActionText,
              side: const BorderSide(color: MealAnalysisLoadingController.errorActionText),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              MealAnalysisLoadingController.retryLabel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _useMockResult,
            style: TextButton.styleFrom(
              foregroundColor: MealAnalysisLoadingController.errorActionText,
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
            child: Text(
              MealAnalysisLoadingController.useMockLabel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: MealAnalysisLoadingController.hintColor,
            padding: EdgeInsets.symmetric(vertical: 8.h),
          ),
          child: Text(
            MealAnalysisLoadingController.backLabel,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
class _LoadingBackground extends StatelessWidget {
  const _LoadingBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MealAnalysisLoadingController.backgroundStart,
            MealAnalysisLoadingController.backgroundEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _GlowBlob(
              size: 220.w,
              offset: Offset(40.w, -30.h),
              opacity: 0.10,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _GlowBlob(
              size: 180.w,
              offset: Offset(-60.w, -40.h),
              opacity: 0.07,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: _GlowBlob(
              size: 200.w,
              offset: Offset(30.w, 60.h),
              opacity: 0.08,
            ),
          ),
        ],
      ),
    );
  }
}
class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.offset,
    required this.opacity,
  });

  final double size;
  final Offset offset;
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              MealAnalysisLoadingController.glowColor.withValues(
                alpha: opacity,
              ),
              MealAnalysisLoadingController.glowColor.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenRingPainter extends CustomPainter {
  _GreenRingPainter({
    required this.progress,
    required this.trackColor,
    required this.activeColor,
    required this.strokeWidth,
  });
  final double progress;
  final Color trackColor;
  final Color activeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const sweep = math.pi * 1.35;
    final start = -math.pi / 2 + progress * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GreenRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
