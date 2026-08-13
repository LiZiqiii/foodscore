import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_page.dart';
import 'sign_up_page_controller.dart';
import '../coaching/coaching_preferences_constants.dart';
import '../config/app_config.dart';
import '../models/auth_user.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/auth_service_factory.dart';
import '../services/user_profile_service_factory.dart';
import '../widgets/auth_form_text_field.dart';
import '../widgets/health_meal_focus_chip.dart';
import '../widgets/page_back_button.dart';

/// 注册页（账号 + 简易 coaching 信息）。
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  final Set<String> _selectedHealth = {CoachingPreferencesConstants.focusNone};
  String? _selectedAgeRange;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _otherHealthController = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  String? _formError;
  bool _isSubmitting = false;
  bool _coachingExpanded = false;

  bool get _otherSelected =>
      _selectedHealth.contains(SignUpPageController.healthOther);

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_clearUsernameError);
    _passwordController.addListener(_clearPasswordError);
  }

  void _clearUsernameError() {
    if (_usernameError == null && _formError == null) {
      return;
    }
    setState(() {
      _usernameError = null;
      _formError = null;
    });
  }

  void _clearPasswordError() {
    if (_passwordError == null && _formError == null) {
      return;
    }
    setState(() {
      _passwordError = null;
      _formError = null;
    });
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearUsernameError);
    _passwordController.removeListener(_clearPasswordError);
    _usernameController.dispose();
    _passwordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _otherHealthController.dispose();
    super.dispose();
  }

  String? _validateUsername(String username) {
    if (username.isEmpty) {
      return SignUpPageController.emptyUsernameMessage;
    }
    if (!SignUpPageController.isValidUsername(username)) {
      return SignUpPageController.invalidUsernameMessage;
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return SignUpPageController.emptyPasswordMessage;
    }
    if (!SignUpPageController.isValidPassword(password)) {
      return SignUpPageController.weakPasswordMessage;
    }
    return null;
  }

  Future<void> _submitSignUp() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final usernameError = _validateUsername(username);
    final passwordError = _validatePassword(password);

    setState(() {
      _usernameError = usernameError;
      _passwordError = passwordError;
      _formError = null;
    });

    if (usernameError != null || passwordError != null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = await createAuthService().register(
        username: username,
        password: password,
      );

      await _saveCoachingProfileAfterRegister(user);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const LoginPage(registrationSuccess: true),
        ),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        if (error.isUsernameConflict) {
          _formError = null;
          _usernameError = SignUpPageController.usernameExistsMessage;
        } else {
          _formError = SignUpPageController.requestFailedMessage;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _formError = SignUpPageController.requestFailedMessage;
      });
    }
  }

  bool _hasCoachingFieldsToSave() {
    if (_selectedAgeRange != null && _selectedAgeRange!.isNotEmpty) {
      return true;
    }
    if (_heightController.text.trim().isNotEmpty ||
        _weightController.text.trim().isNotEmpty) {
      return true;
    }
    if (CoachingPreferencesConstants.conditionsForSave(_selectedHealth)
        .isNotEmpty) {
      return true;
    }
    return _otherSelected && _otherHealthController.text.trim().isNotEmpty;
  }

  Future<void> _saveCoachingProfileAfterRegister(AuthUser user) async {
    if (AppConfig.useMockResult || !_hasCoachingFieldsToSave()) {
      return;
    }

    final otherNote = _otherSelected
        ? _trimOrNull(_otherHealthController.text)
        : null;

    final profile = UserProfile(
      userId: user.apiUserId,
      ageRange: _selectedAgeRange,
      heightCm: _trimOrNull(_heightController.text),
      weightKg: _trimOrNull(_weightController.text),
      healthConditions:
          CoachingPreferencesConstants.conditionsForSave(_selectedHealth),
      healthOtherNote: otherNote,
    );

    try {
      await createUserProfileService().saveProfile(profile);
    } catch (_) {
      // Optional coaching — do not block account creation.
    }
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SignUpPageController.bgBottom,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SignUpPageController.bgTop,
              SignUpPageController.bgMid,
              SignUpPageController.bgBottom,
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SignUpPageController.horizontalPadding.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: SignUpPageController.topInset.h),
                        const PageBackButton(),
                        SizedBox(height: SignUpPageController.backToTitleGap.h),
                        Text(
                          SignUpPageController.title,
                          style: TextStyle(
                            fontSize: SignUpPageController.titleFontSize.sp,
                            fontWeight: FontWeight.w600,
                            color: SignUpPageController.titleColor,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: SignUpPageController.titleToFormGap.h),
                        _buildAccountFields(),
                        if (_formError != null) ...[
                          SizedBox(height: SignUpPageController.fieldErrorGap.h),
                          Text(
                            _formError!,
                            style: TextStyle(
                              fontSize: SignUpPageController.errorFontSize.sp,
                              fontWeight: FontWeight.w400,
                              color: SignUpPageController.errorTextColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                        SizedBox(height: SignUpPageController.sectionGap.h),
                        _buildCoachingSection(),
                        SizedBox(height: SignUpPageController.formToButtonGap.h),
                        _buildCreateAccountButton(context),
                        SizedBox(
                          height: SignUpPageController.buttonToFooterGap.h,
                        ),
                        _buildLogInFooter(context),
                        SizedBox(height: 28.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAccountFields() {
    return Column(
      children: [
        _buildValidatedField(
          errorText: _usernameError,
          field: _buildInputField(
            hint: SignUpPageController.usernameHint,
            controller: _usernameController,
            hasError: _usernameError != null,
          ),
        ),
        SizedBox(height: SignUpPageController.inputGap.h),
        _buildValidatedField(
          errorText: _passwordError,
          field: _buildInputField(
            hint: SignUpPageController.passwordHint,
            controller: _passwordController,
            obscureText: _obscurePassword,
            hasError: _passwordError != null,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20.sp,
                color: SignUpPageController.hintColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidatedField({
    required Widget field,
    required String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        if (errorText != null) ...[
          SizedBox(height: SignUpPageController.fieldErrorGap.h),
          Text(
            errorText,
            style: TextStyle(
              fontSize: SignUpPageController.errorFontSize.sp,
              fontWeight: FontWeight.w400,
              color: SignUpPageController.errorTextColor,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoachingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSubmitting
                ? null
                : () {
                    setState(() => _coachingExpanded = !_coachingExpanded);
                  },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCoachingLabelIcon(),
                            SizedBox(
                              width: SignUpPageController.coachingLabelIconGap.w,
                            ),
                            Expanded(
                              child: Text.rich(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: SignUpPageController.coachingLabel,
                                      style: TextStyle(
                                        fontSize: SignUpPageController
                                            .coachingTitleFontSize.sp,
                                        fontWeight: FontWeight.w600,
                                        color: SignUpPageController
                                            .sectionTitleColor,
                                        height: 1.2,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${SignUpPageController.coachingOptionalSuffix}',
                                      style: TextStyle(
                                        fontSize: SignUpPageController
                                            .coachingOptionalFontSize.sp,
                                        fontWeight: FontWeight.w400,
                                        color: SignUpPageController
                                            .coachingSubsectionColor,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!_coachingExpanded) ...[
                          SizedBox(
                            height: SignUpPageController.coachingCollapsedHintTopGap.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: SignUpPageController.coachingLabelIconSize.sp +
                                  SignUpPageController.coachingLabelIconGap.w,
                            ),
                            child: Text(
                              SignUpPageController.coachingCollapsedHint,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: SignUpPageController
                                    .coachingSectionFontSize.sp,
                                fontWeight: FontWeight.w400,
                                color: SignUpPageController
                                    .coachingSubsectionColor,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: AnimatedRotation(
                      turns: _coachingExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: SignUpPageController.coachingSubsectionColor,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: _coachingExpanded
              ? Padding(
                  padding: EdgeInsets.only(top: SignUpPageController.coachingInnerGap.h),
                  child: _buildCoachingExpandedFields(),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildCoachingLabelIcon() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          SignUpPageController.coachingLabelIconGradientStart,
          SignUpPageController.coachingLabelIconGradientEnd,
        ],
      ).createShader(bounds),
      child: Icon(
        Icons.person_rounded,
        size: SignUpPageController.coachingLabelIconSize.sp,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCoachingExpandedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoachingSubsectionTitle(SignUpPageController.aboutYouSection),
        SizedBox(height: SignUpPageController.coachingSubsectionTopGap.h),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                hint: SignUpPageController.heightHint,
                controller: _heightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                flat: true,
              ),
            ),
            SizedBox(width: SignUpPageController.metricsGap.w),
            Expanded(
              child: _buildInputField(
                hint: SignUpPageController.weightHint,
                controller: _weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                flat: true,
              ),
            ),
          ],
        ),
        SizedBox(height: SignUpPageController.coachingInnerGap.h),
        _buildAgeRangeDropdown(),
        SizedBox(height: SignUpPageController.coachingInnerGap.h),
        _buildCoachingSubsectionTitle(
          SignUpPageController.healthConsiderationsLabel,
        ),
        SizedBox(height: SignUpPageController.coachingSubsectionTopGap.h),
        Wrap(
          spacing: SignUpPageController.chipGap.w,
          runSpacing: SignUpPageController.chipGap.h,
          children: [
            for (final option in SignUpPageController.healthOptions)
              _buildHealthChip(option),
          ],
        ),
        if (_otherSelected) ...[
          SizedBox(height: SignUpPageController.otherFieldGap.h),
          _buildInputField(
            hint: SignUpPageController.otherHealthHint,
            controller: _otherHealthController,
            maxLength: SignUpPageController.otherHealthMaxLength,
            flat: true,
          ),
        ],
      ],
    );
  }

  Widget _buildCoachingSubsectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: SignUpPageController.coachingSectionFontSize.sp,
        fontWeight: FontWeight.w500,
        color: SignUpPageController.coachingSubsectionColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildAgeRangeDropdown() {
    final borderRadius = BorderRadius.circular(
      SignUpPageController.inputBorderRadius.r,
    );
    final fieldHeight = SignUpPageController.inputHeight.h;

    return Container(
      height: fieldHeight,
      decoration: BoxDecoration(
        color: SignUpPageController.inputBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: SignUpPageController.inputBorderColor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAgeRange,
          isExpanded: true,
          isDense: true,
          hint: Text(
            SignUpPageController.ageRangePlaceholder,
            style: TextStyle(
              fontSize: SignUpPageController.inputFontSize.sp,
              fontWeight: FontWeight.w400,
              color: SignUpPageController.hintColor,
              height: 1.0,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: SignUpPageController.hintColor,
            size: 22.sp,
          ),
          items: SignUpPageController.ageRangeOptions
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: SignUpPageController.inputFontSize.sp,
                      fontWeight: FontWeight.w500,
                      color: SignUpPageController.inputTextColor,
                      height: 1.0,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: _isSubmitting
              ? null
              : (value) {
                  setState(() => _selectedAgeRange = value);
                },
        ),
      ),
    );
  }

  void _toggleHealthOption(String label) {
    setState(() {
      CoachingPreferencesConstants.toggleMealFocus(_selectedHealth, label);
      if (!_selectedHealth.contains(SignUpPageController.healthOther)) {
        _otherHealthController.clear();
      }
    });
  }

  Widget _buildHealthChip(String label) {
    final selected = _selectedHealth.contains(label);

    return HealthMealFocusChip(
      label: label,
      selected: selected,
      onTap: () => _toggleHealthOption(label),
      height: SignUpPageController.chipHeight,
      fontSize: SignUpPageController.chipFontSize,
      selectedBackground: SignUpPageController.chipBgSelected,
      unselectedBackground: SignUpPageController.inputBackgroundColor,
      outlineColor: SignUpPageController.chipOutlineColor,
      selectedTextColor: SignUpPageController.chipTextSelected,
      unselectedTextColor: SignUpPageController.chipText,
      enabled: !_isSubmitting,
    );
  }

  Widget _buildInputField({
    required String hint,
    bool obscureText = false,
    bool hasError = false,
    bool flat = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    int? maxLength,
  }) {
    return AuthFormTextField(
      height: SignUpPageController.inputHeight,
      hint: hint,
      controller: controller,
      obscureText: obscureText,
      enabled: !_isSubmitting,
      hasError: hasError,
      suffixIcon: suffixIcon,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      useShadow: !flat,
      backgroundColor: SignUpPageController.inputBackgroundColor,
      borderColor: SignUpPageController.inputBorderColor,
      errorBorderColor: SignUpPageController.inputErrorBorderColor,
      textColor: SignUpPageController.inputTextColor,
      hintColor: SignUpPageController.hintColor,
      fontSize: SignUpPageController.inputFontSize,
      hintFontSize: SignUpPageController.hintFontSize,
      borderRadius: SignUpPageController.inputBorderRadius,
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      SignUpPageController.buttonBorderRadius.r,
    );

    return Material(
      color: SignUpPageController.buttonColor,
      elevation: SignUpPageController.buttonElevation,
      shadowColor: const Color(0xFF4A9E68).withValues(alpha: 0.35),
      borderRadius: borderRadius,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: _isSubmitting ? null : _submitSignUp,
        borderRadius: borderRadius,
        splashColor: Colors.white.withValues(alpha: 0.28),
        highlightColor: Colors.white.withValues(alpha: 0.14),
        child: SizedBox(
          width: double.infinity,
          height: SignUpPageController.buttonHeight.h,
          child: Center(
            child: _isSubmitting
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: SignUpPageController.buttonTextColor,
                    ),
                  )
                : Text(
                    SignUpPageController.createAccountButton,
                    style: TextStyle(
                      fontSize: SignUpPageController.buttonFontSize.sp,
                      fontWeight: FontWeight.w700,
                      color: SignUpPageController.buttonTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogInFooter(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const LoginPage(),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: SignUpPageController.hasAccountPrefix,
                style: TextStyle(
                  fontSize: SignUpPageController.linkFontSize.sp,
                  fontWeight: FontWeight.w500,
                  color: SignUpPageController.footerTextColor,
                ),
              ),
              TextSpan(
                text: SignUpPageController.logIn,
                style: TextStyle(
                  fontSize: SignUpPageController.linkFontSize.sp,
                  fontWeight: FontWeight.w600,
                  color: SignUpPageController.linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: SignUpPageController.linkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
