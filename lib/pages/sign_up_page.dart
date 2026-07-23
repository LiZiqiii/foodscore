import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'food_score_home_page.dart';
import 'login_page.dart';
import 'sign_up_page_controller.dart';
import '../widgets/page_back_button.dart';

/// 注册页（账号 + 简易 coaching 信息）。
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  final Set<String> _selectedHealth = {};
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otherHealthController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  bool get _otherSelected =>
      _selectedHealth.contains(SignUpPageController.healthOther);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearEmailError);
    _passwordController.addListener(_clearPasswordError);
  }

  void _clearEmailError() {
    if (_emailError == null) {
      return;
    }
    setState(() => _emailError = null);
  }

  void _clearPasswordError() {
    if (_passwordError == null) {
      return;
    }
    setState(() => _passwordError = null);
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearEmailError);
    _passwordController.removeListener(_clearPasswordError);
    _emailController.dispose();
    _passwordController.dispose();
    _otherHealthController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return SignUpPageController.emptyEmailMessage;
    }
    if (!SignUpPageController.isValidEmail(email)) {
      return SignUpPageController.invalidEmailMessage;
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

  void _submitSignUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const FoodScoreHomePage(),
      ),
    );
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
          errorText: _emailError,
          field: _buildInputField(
            hint: SignUpPageController.emailHint,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hasError: _emailError != null,
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
        Text(
          SignUpPageController.coachingLabel,
          style: TextStyle(
            fontSize: SignUpPageController.sectionTitleFontSize.sp,
            fontWeight: FontWeight.w600,
            color: SignUpPageController.sectionTitleColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: SignUpPageController.coachingLabelGap.h),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                hint: SignUpPageController.heightHint,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            SizedBox(width: SignUpPageController.metricsGap.w),
            Expanded(
              child: _buildInputField(
                hint: SignUpPageController.weightHint,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        SizedBox(height: SignUpPageController.coachingLabelGap.h),
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
          ),
        ],
      ],
    );
  }

  void _toggleHealthOption(String label) {
    setState(() {
      if (label == SignUpPageController.healthOther) {
        if (_selectedHealth.contains(label)) {
          _selectedHealth.remove(label);
          _otherHealthController.clear();
        } else {
          _selectedHealth.add(label);
        }
        return;
      }

      if (_selectedHealth.contains(label)) {
        _selectedHealth.remove(label);
      } else {
        _selectedHealth.add(label);
      }
    });
  }

  Widget _buildHealthChip(String label) {
    final selected = _selectedHealth.contains(label);

    return GestureDetector(
      onTap: () => _toggleHealthOption(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: SignUpPageController.chipHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? SignUpPageController.chipBgSelected
              : SignUpPageController.chipBg,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: SignUpPageController.chipFontSize.sp,
            fontWeight: FontWeight.w500,
            color: selected
                ? SignUpPageController.chipTextSelected
                : SignUpPageController.chipText,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    bool obscureText = false,
    bool hasError = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    int? maxLength,
  }) {
    final borderRadius = BorderRadius.circular(
      SignUpPageController.inputBorderRadius.r,
    );
    final borderColor = hasError
        ? SignUpPageController.inputErrorBorderColor
        : SignUpPageController.inputBorderColor;

    return Container(
      height: SignUpPageController.inputHeight.h,
      decoration: BoxDecoration(
        color: SignUpPageController.inputBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: 1,
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
      padding: EdgeInsets.only(
        left: 16.w,
        right: suffixIcon == null ? 16.w : 4.w,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
            null,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: SignUpPageController.inputFontSize.sp,
          fontWeight: FontWeight.w500,
          color: SignUpPageController.inputTextColor,
          height: 1.0,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: SignUpPageController.hintFontSize.sp,
            fontWeight: FontWeight.w400,
            color: SignUpPageController.hintColor,
            height: 1.0,
          ),
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          suffixIcon: suffixIcon,
        ),
      ),
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
        onTap: _submitSignUp,
        borderRadius: borderRadius,
        splashColor: Colors.white.withValues(alpha: 0.28),
        highlightColor: Colors.white.withValues(alpha: 0.14),
        child: SizedBox(
          width: double.infinity,
          height: SignUpPageController.buttonHeight.h,
          child: Center(
            child: Text(
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
