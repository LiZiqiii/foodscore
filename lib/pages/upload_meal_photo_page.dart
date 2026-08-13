import 'dart:io';

import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'meal_analysis_loading_page.dart';
import '../config/page_layout.dart';
import '../widgets/page_back_button.dart';
import 'describe_meal_page.dart';
import 'describe_meal_page_controller.dart';
import 'upload_meal_photo_controller.dart';
/// 上传餐食照片页面。
class UploadMealPhotoPage extends StatefulWidget {
  const UploadMealPhotoPage({
    super.key,
    this.showImageSourceSheetOnOpen = false,
  });

  final bool showImageSourceSheetOnOpen;

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
  void initState() {
    super.initState();
    if (widget.showImageSourceSheetOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showImageSourceSheet();
        }
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionScrollController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (sheetContext) => _ImageSourceSheet(
        onTakePhoto: () {
          Navigator.of(sheetContext).pop();
          _pickImage(ImageSource.camera);
        },
        onChooseGallery: () {
          Navigator.of(sheetContext).pop();
          _pickImage(ImageSource.gallery);
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // No maxWidth / maxHeight / imageQuality — keep the user's original file for API upload.
    final image = await _imagePicker.pickImage(source: source);
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: UploadMealPhotoController.horizontalPadding.w,
          ),
          child: SingleChildScrollView(
            child: _buildScrollContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollContent(BuildContext context) {
    return Column(
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
        SizedBox(height: 12.h),
        _buildTextInputLink(context),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          UploadMealPhotoController.title,
          style: TextStyle(
            fontSize: MealFlowPageStyle.titleFontSize.sp,
            fontWeight: FontWeight.w600,
            color: MealFlowPageStyle.titleColor,
            height: MealFlowPageStyle.titleLineHeight,
          ),
        ),
        SizedBox(height: MealFlowPageStyle.titleToSubtitleGap.h),
        Text(
          UploadMealPhotoController.subtitle.trim(),
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

  Widget _buildUploadArea() {
    final radius = UploadMealPhotoController.uploadAreaRadius.r;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showImageSourceSheet,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: UploadMealPhotoController.uploadIconSize.sp,
                color: UploadMealPhotoController.uploadIconColor,
              ),
              SizedBox(
                height: UploadMealPhotoController.uploadIconToHintGap.h,
              ),
              Text(
                UploadMealPhotoController.uploadHint,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: UploadMealPhotoController.uploadHintColor,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
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
      topLeft: Radius.circular(DescribeMealPageController.inputRadiusTL.r),
      topRight: Radius.circular(DescribeMealPageController.inputRadiusTR.r),
      bottomLeft: Radius.circular(DescribeMealPageController.inputRadiusBL.r),
      bottomRight: Radius.circular(DescribeMealPageController.inputRadiusBR.r),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return false;
      },
      child: SizedBox(
        width: double.infinity,
        height: UploadMealPhotoController.descriptionInputHeight.h,
        child: Scrollbar(
          controller: _descriptionScrollController,
          thumbVisibility: true,
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
              color: DescribeMealPageController.inputTextColor,
              height: DescribeMealPageController.inputLineHeight,
            ),
            decoration: InputDecoration(
              hintText: UploadMealPhotoController.descriptionHint,
              hintStyle: TextStyle(
                fontSize: UploadMealPhotoController.descriptionHintFontSize.sp,
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
      ),
    );
  }

  Widget _buildTextInputLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DescribeMealPage(),
            ),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: UploadMealPhotoController.uploadIconColor,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          UploadMealPhotoController.enterMealAsTextLabel,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: UploadMealPhotoController.uploadIconColor
                .withValues(alpha: 0.45),
            height: 1.3,
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
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MealAnalysisLoadingPage(
                      imagePath: _selectedImage!.path,
                      imageFile: _selectedImage,
                      description: _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
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
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet({
    required this.onTakePhoto,
    required this.onChooseGallery,
  });

  final VoidCallback onTakePhoto;
  final VoidCallback onChooseGallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UploadMealPhotoController.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              UploadMealPhotoController.imageSourceSheetTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: UploadMealPhotoController.descriptionLabelColor,
                height: 1.25,
              ),
            ),
            SizedBox(height: 18.h),
            _ImageSourceOption(
              icon: Icons.photo_camera_outlined,
              label: UploadMealPhotoController.takePhotoOption,
              onTap: onTakePhoto,
            ),
            SizedBox(height: 12.h),
            _ImageSourceOption(
              icon: Icons.photo_library_outlined,
              label: UploadMealPhotoController.chooseGalleryOption,
              onTap: onChooseGallery,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: UploadMealPhotoController.uploadIconColor.withValues(
          alpha: 0.08,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: UploadMealPhotoController.uploadAreaBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: UploadMealPhotoController.uploadIconColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: UploadMealPhotoController.descriptionLabelColor,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
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
