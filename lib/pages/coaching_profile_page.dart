import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../coaching/coaching_preferences_constants.dart';
import '../models/user_profile.dart';
import '../services/meal_record_service_factory.dart';
import '../services/user_profile_service.dart';
import '../services/user_profile_service_factory.dart';
import '../widgets/health_meal_focus_chip.dart';
import '../widgets/page_back_button.dart';
import 'coaching_profile_page_controller.dart';

/// View and edit optional coaching profile for personalised suggestions.
class CoachingProfilePage extends StatefulWidget {
  const CoachingProfilePage({super.key});
  @override
  State<CoachingProfilePage> createState() => _CoachingProfilePageState();
}

class _CoachingProfilePageState extends State<CoachingProfilePage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _otherNoteController = TextEditingController();
  String? _selectedAgeRange;
  final Set<String> _selectedMealFocus = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  String? _saveError;
  bool get _otherSelected =>
      _selectedMealFocus.contains(CoachingPreferencesConstants.focusOther);
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _otherNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final profile = await createUserProfileService().loadProfile(
        currentUserId,
      );
      if (!mounted) {
        return;
      }
      _applyProfile(profile ?? UserProfile.empty(currentUserId));
      setState(() => _isLoading = false);
    } on UserProfileServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadError = CoachingProfilePageController.loadFailedMessage;
      });
    }
  }

  void _applyProfile(UserProfile profile) {
    _selectedAgeRange = _valueInOptions(
      profile.ageRange,
      CoachingProfilePageController.ageRangeOptions,
    );
    _heightController.text = profile.heightCm ?? '';
    _weightController.text = profile.weightKg ?? '';
    _selectedMealFocus
      ..clear()
      ..addAll(
        CoachingPreferencesConstants.mealFocusFromProfile(
          healthConditions: profile.healthConditions,
          healthContext: profile.healthContext,
          healthOtherNote: profile.healthOtherNote,
        ),
      );
    final otherNote = CoachingPreferencesConstants.otherNoteFromProfile(
      healthConditions: profile.healthConditions,
      healthOtherNote: profile.healthOtherNote,
    );
    _otherNoteController.text = otherNote ?? '';

    final dietary = profile.dietaryPreference?.trim();
    if (dietary != null &&
        dietary.isNotEmpty &&
        _otherNoteController.text.isEmpty) {
      _selectedMealFocus.add(CoachingPreferencesConstants.focusOther);
      _otherNoteController.text = dietary;
    }
  }

  String? _valueInOptions(String? value, List<String> options) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (options.contains(value)) {
      return value;
    }
    return null;
  }

  List<String> _mealFocusConditionsForSave() {
    return CoachingPreferencesConstants.conditionsForSave(_selectedMealFocus);
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    final otherNote = _otherSelected
        ? _trimOrNull(_otherNoteController.text)
        : null;
    final profile = UserProfile(
      userId: currentUserId,
      ageRange: _selectedAgeRange,
      heightCm: _trimOrNull(_heightController.text),
      weightKg: _trimOrNull(_weightController.text),
      dietaryPreference: null,
      healthContext: null,
      healthConditions: _mealFocusConditionsForSave(),
      healthOtherNote: otherNote,
    );
    try {
      await createUserProfileService().saveProfile(profile);
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(CoachingProfilePageController.saveSuccessMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on UserProfileServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _saveError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _saveError = CoachingProfilePageController.saveFailedMessage;
      });
    }
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _toggleMealFocus(String label) {
    setState(() {
      CoachingPreferencesConstants.toggleMealFocus(_selectedMealFocus, label);
      if (!_selectedMealFocus.contains(CoachingPreferencesConstants.focusOther)) {
        _otherNoteController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoachingProfilePageController.bgBottom,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CoachingProfilePageController.bgTop,
              CoachingProfilePageController.bgMid,
              CoachingProfilePageController.bgBottom,
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(child: _isLoading ? _buildLoading() : _buildContent()),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: SizedBox(
        width: 28.w,
        height: 28.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2.4,
          color: CoachingProfilePageController.titleColor,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: CoachingProfilePageController.horizontalPadding.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: CoachingProfilePageController.topInset.h),
                  const PageBackButton(),
                  SizedBox(
                    height: CoachingProfilePageController.backToTitleGap.h,
                  ),
                  Text(
                    CoachingProfilePageController.title,
                    style: TextStyle(
                      fontSize: CoachingProfilePageController.titleFontSize.sp,
                      fontWeight: FontWeight.w600,
                      color: CoachingProfilePageController.titleColor,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(
                    height:
                        CoachingProfilePageController.titleToExplanationGap.h,
                  ),
                  Text(
                    CoachingProfilePageController.explanation,
                    style: TextStyle(
                      fontSize: CoachingProfilePageController.bodyFontSize.sp,
                      fontWeight: FontWeight.w400,
                      color: CoachingProfilePageController.bodyTextColor,
                      height: 1.45,
                    ),
                  ),
                  if (_loadError != null) ...[
                    SizedBox(height: CoachingProfilePageController.fieldGap.h),
                    Text(
                      _loadError!,
                      style: TextStyle(
                        fontSize:
                            CoachingProfilePageController.errorFontSize.sp,
                        color: CoachingProfilePageController.errorTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                  SizedBox(
                    height:
                        CoachingProfilePageController.explanationToFormGap.h,
                  ),
                  _buildAboutYouSection(),
                  SizedBox(
                    height: CoachingProfilePageController.fieldGap.h + 4.h,
                  ),
                  _buildMealFocusSection(),
                  if (_saveError != null) ...[
                    SizedBox(height: CoachingProfilePageController.fieldGap.h),
                    Text(
                      _saveError!,
                      style: TextStyle(
                        fontSize:
                            CoachingProfilePageController.errorFontSize.sp,
                        color: CoachingProfilePageController.errorTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                  SizedBox(
                    height: CoachingProfilePageController.formToButtonGap.h,
                  ),
                  _buildSaveButton(),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: CoachingProfilePageController.labelFontSize.sp,
        fontWeight: FontWeight.w600,
        color: CoachingProfilePageController.bodyTextColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildAboutYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(CoachingProfilePageController.aboutYouSection),
        SizedBox(height: CoachingProfilePageController.labelGap.h),
        Text(
          CoachingProfilePageController.ageLabel,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: CoachingProfilePageController.subtitleLabelColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: 6.h),
        _buildDropdownContainer(
          value: _selectedAgeRange,
          placeholder: CoachingProfilePageController.ageRangePlaceholder,
          options: CoachingProfilePageController.ageRangeOptions,
          onChanged: _isSaving
              ? null
              : (value) {
                  setState(() => _selectedAgeRange = value);
                },
        ),
        SizedBox(height: CoachingProfilePageController.fieldGap.h),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                hint: CoachingProfilePageController.heightHint,
                controller: _heightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildInputField(
                hint: CoachingProfilePageController.weightHint,
                controller: _weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealFocusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeading(CoachingProfilePageController.mealFocusLabel),
        SizedBox(height: CoachingProfilePageController.labelGap.h),
        Wrap(
          spacing: CoachingProfilePageController.chipGap.w,
          runSpacing: CoachingProfilePageController.chipGap.h,
          children: [
            for (final option in CoachingPreferencesConstants.mealFocusOptions)
              _buildMealFocusChip(option),
          ],
        ),
        if (_otherSelected) ...[
          SizedBox(height: 10.h),
          _buildInputField(
            hint: CoachingPreferencesConstants.otherNoteHint,
            controller: _otherNoteController,
            maxLength: CoachingPreferencesConstants.otherNoteMaxLength,
          ),
        ],
      ],
    );
  }

  Widget _buildMealFocusChip(String label) {
    final selected = _selectedMealFocus.contains(label);
    return HealthMealFocusChip(
      label: label,
      selected: selected,
      onTap: _isSaving ? null : () => _toggleMealFocus(label),
      height: CoachingProfilePageController.chipHeight,
      fontSize: CoachingProfilePageController.chipFontSize,
      selectedBackground: CoachingProfilePageController.chipBgSelected,
      unselectedBackground: CoachingProfilePageController.inputBackgroundColor,
      outlineColor: CoachingProfilePageController.inputBorderColor,
      selectedTextColor: CoachingProfilePageController.chipTextSelected,
      unselectedTextColor: CoachingProfilePageController.chipText,
      enabled: !_isSaving,
    );
  }

  Widget _buildDropdownContainer({
    required String? value,
    required String placeholder,
    required List<String> options,
    required ValueChanged<String?>? onChanged,
  }) {
    final borderRadius = BorderRadius.circular(
      CoachingProfilePageController.inputBorderRadius.r,
    );
    return Container(
      height: CoachingProfilePageController.inputHeight.h,
      decoration: BoxDecoration(
        color: CoachingProfilePageController.inputBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: CoachingProfilePageController.inputBorderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A6731).withValues(alpha: 0.04),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            placeholder,
            style: TextStyle(
              fontSize: CoachingProfilePageController.inputFontSize.sp,
              fontWeight: FontWeight.w400,
              color: CoachingProfilePageController.hintColor,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: CoachingProfilePageController.hintColor,
            size: 22.sp,
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: CoachingProfilePageController.inputFontSize.sp,
                      fontWeight: FontWeight.w500,
                      color: CoachingProfilePageController.inputTextColor,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    final borderRadius = BorderRadius.circular(
      CoachingProfilePageController.inputBorderRadius.r,
    );
    return Container(
      height: CoachingProfilePageController.inputHeight.h,
      decoration: BoxDecoration(
        color: CoachingProfilePageController.inputBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: CoachingProfilePageController.inputBorderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A6731).withValues(alpha: 0.04),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: controller,
        enabled: !_isSaving,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: CoachingProfilePageController.inputFontSize.sp,
          fontWeight: FontWeight.w500,
          color: CoachingProfilePageController.inputTextColor,
          height: 1.0,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: CoachingProfilePageController.inputFontSize.sp,
            fontWeight: FontWeight.w400,
            color: CoachingProfilePageController.hintColor,
            height: 1.0,
          ),
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final borderRadius = BorderRadius.circular(
      CoachingProfilePageController.buttonBorderRadius.r,
    );
    return Material(
      color: CoachingProfilePageController.buttonColor,
      elevation: CoachingProfilePageController.buttonElevation,
      shadowColor: const Color(0xFF4A9E68).withValues(alpha: 0.35),
      borderRadius: borderRadius,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: _isSaving ? null : _saveProfile,
        borderRadius: borderRadius,
        splashColor: Colors.white.withValues(alpha: 0.28),
        highlightColor: Colors.white.withValues(alpha: 0.14),
        child: SizedBox(
          width: double.infinity,
          height: CoachingProfilePageController.buttonHeight.h,
          child: Center(
            child: _isSaving
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: CoachingProfilePageController.buttonTextColor,
                    ),
                  )
                : Text(
                    CoachingProfilePageController.saveButton,
                    style: TextStyle(
                      fontSize: CoachingProfilePageController.buttonFontSize.sp,
                      fontWeight: FontWeight.w700,
                      color: CoachingProfilePageController.buttonTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
