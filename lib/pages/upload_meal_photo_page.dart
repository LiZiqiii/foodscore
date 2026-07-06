import 'dart:io';

import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'meal_analysis_loading_page.dart';
import '../config/page_layout.dart';
import '../widgets/meal_feedback_mode_selector.dart';
import '../widgets/page_back_button.dart';
import 'upload_meal_photo_controller.dart';
/// 上传餐食照片页面。
class UploadMealPhotoPage extends StatefulWidget {
  const UploadMealPhotoPage({super.key});

  @override
  State<UploadMealPhotoPage> createState() => _UploadMealPhotoPageState();
}

class _UploadMealPhotoPageState extends State<UploadMealPhotoPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _descriptionScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  bool get _hasPhoto => _selectedImage != null;

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) {
      return;
    }
    setState(() => _selectedImage = image);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UploadMealPhotoController.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _buildContent(context),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: UploadMealPhotoController.horizontalPadding.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: PageLayout.topExtraPadding.h),
          const PageBackButton(),
          SizedBox(height: PageLayout.backToTitleGap.h),
          _buildTitleSection(),
          SizedBox(height: UploadMealPhotoController.subtitleToUploadGap.h),
          _buildUploadArea(),
          SizedBox(height: 24.h),
          Text(
            UploadMealPhotoController.descriptionLabel,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: UploadMealPhotoController.descriptionLabelColor,
              height: 1.2,
            ),
          ),
          SizedBox(
            height: UploadMealPhotoController.descriptionLabelToOptionalGap.h,
          ),
          Text(
            UploadMealPhotoController.descriptionOptional,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: UploadMealPhotoController.descriptionOptionalColor,
              height: 1.2,
            ),
          ),
          SizedBox(height: UploadMealPhotoController.optionalToInputGap.h),
          _buildDescriptionField(),
          SizedBox(height: UploadMealPhotoController.descriptionToCtaGap.h),
          _buildCtaButton(context),
          SizedBox(height: UploadMealPhotoController.ctaToDisclaimerGap.h),
          _buildDisclaimer(),
          SizedBox(height: UploadMealPhotoController.disclaimerBottomPadding.h),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UploadMealPhotoController.title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: UploadMealPhotoController.titleColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: UploadMealPhotoController.titleToSubtitleGap.h),
        Text(
          UploadMealPhotoController.subtitle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: UploadMealPhotoController.subtitleFontSize.sp,
            fontWeight: FontWeight.w400,
            color: UploadMealPhotoController.subtitleColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    final radius = UploadMealPhotoController.uploadAreaRadius.r;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(radius),
        splashColor: UploadMealPhotoController.uploadIconColor.withValues(
          alpha: 0.08,
        ),
        child: CustomPaint(
          foregroundPainter: _DashedRRectPainter(
            color: UploadMealPhotoController.uploadAreaBorder,
            borderRadius: radius,
            strokeWidth: 2,
            dashWidth: 7,
            dashGap: 5,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              width: double.infinity,
              height: UploadMealPhotoController.uploadAreaHeight.h,
              decoration: BoxDecoration(
                color: UploadMealPhotoController.uploadAreaBg,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: _selectedImage == null
                  ? _buildUploadPlaceholder()
                  : _buildImagePreview(_selectedImage!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: UploadMealPhotoController.uploadIconSize.sp,
          color: UploadMealPhotoController.uploadIconColor,
        ),
        SizedBox(height: UploadMealPhotoController.uploadIconToHintGap.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            UploadMealPhotoController.uploadHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: UploadMealPhotoController.uploadHintColor,
              height: 25 / 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(XFile file) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.file(
      File(file.path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
  Widget _buildDescriptionField() {
    final radius = BorderRadius.only(
      topLeft: Radius.circular(
        UploadMealPhotoController.descriptionInputRadiusTL.r,
      ),
      topRight: Radius.circular(
        UploadMealPhotoController.descriptionInputRadiusTR.r,
      ),
      bottomLeft: Radius.circular(
        UploadMealPhotoController.descriptionInputRadiusBL.r,
      ),
      bottomRight: Radius.circular(
        UploadMealPhotoController.descriptionInputRadiusBR.r,
      ),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return false;
      },
      child: SizedBox(
        width: double.infinity,
        height: UploadMealPhotoController.descriptionInputHeight.h,
        child: TextField(
          controller: _descriptionController,
          scrollController: _descriptionScrollController,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: UploadMealPhotoController.descriptionInputFontSize.sp,
          fontWeight: FontWeight.w400,
          color: UploadMealPhotoController.descriptionTextColor,
          height: UploadMealPhotoController.descriptionInputLineHeight,
        ),
        decoration: InputDecoration(
          hintText: UploadMealPhotoController.descriptionHint,
          hintStyle: TextStyle(
            fontSize: UploadMealPhotoController.descriptionInputFontSize.sp,
            fontWeight: FontWeight.w400,
            color: UploadMealPhotoController.descriptionHintColor,
            height: UploadMealPhotoController.descriptionInputLineHeight,
          ),
          filled: true,
          fillColor: UploadMealPhotoController.descriptionInputBg,
          contentPadding: EdgeInsets.symmetric(
            horizontal: UploadMealPhotoController.descriptionInputPaddingH.w,
            vertical: UploadMealPhotoController.descriptionInputPaddingV.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(
              color: UploadMealPhotoController.descriptionInputBorder,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: UploadMealPhotoController.backColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(
              color: UploadMealPhotoController.descriptionInputBorder,
              width: 1,
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    final enabled = _hasPhoto;
    final bgColor = enabled
        ? UploadMealPhotoController.ctaEnabledBg
        : UploadMealPhotoController.ctaDisabledBg;
    final textColor = enabled
        ? Colors.white
        : UploadMealPhotoController.ctaDisabledText;
    final borderRadius = BorderRadius.circular(
      PageLayout.primaryButtonRadius.r,
    );

    return Material(
      color: bgColor,
      elevation: enabled ? 2.5 : 0,
      shadowColor: enabled
          ? UploadMealPhotoController.ctaEnabledBg.withValues(alpha: 0.28)
          : Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: enabled
            ? () {
                showMealFeedbackModeSheet(
                  context,
                  onInstantFeedback: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MealAnalysisLoadingPage(
                          imagePath: _selectedImage!.path,
                          description:
                              _descriptionController.text.trim().isEmpty
                              ? null
                              : _descriptionController.text.trim(),
                        ),
                      ),
                    );
                  },
                  onWeeklyReflection: () {
                    final description = _descriptionController.text.trim();
                    saveMealForWeeklyReflection(
                      context,
                      summary: description.isEmpty
                          ? 'Meal photo'
                          : description,
                      isPhoto: true,
                    );
                  },
                );
              }
            : null,
        borderRadius: borderRadius,
        splashColor: enabled ? Colors.white.withValues(alpha: 0.18) : null,
        highlightColor: enabled ? Colors.white.withValues(alpha: 0.08) : null,
        child: SizedBox(
          width: double.infinity,
          height: UploadMealPhotoController.ctaHeight.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                UploadMealPhotoController.ctaLabel,
                style: TextStyle(
                  fontSize: UploadMealPhotoController.ctaFontSize.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.15,
                ),
              ),
              SizedBox(width: UploadMealPhotoController.ctaIconGap.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: UploadMealPhotoController.ctaIconSize.sp,
                color: textColor,
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
        '${UploadMealPhotoController.disclaimerLine1}\n'
        '${UploadMealPhotoController.disclaimerLine2}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: UploadMealPhotoController.disclaimerColor,
          height: 1.4,
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.borderRadius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final inset = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
