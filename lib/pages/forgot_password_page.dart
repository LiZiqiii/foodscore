import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import 'forgot_password_page_controller.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../services/auth_service_factory.dart';
import '../widgets/auth_form_text_field.dart';
import '../widgets/page_back_button.dart';

/// Forgot password page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  String? _formError;
  bool _obscurePassword = true;
  bool _updated = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_clearUsernameError);
    _passwordController.addListener(_clearPasswordError);
  }

  void _clearUsernameError() {
    if (_usernameError == null) {
      return;
    }
    setState(() => _usernameError = null);
  }

  void _clearPasswordError() {
    if (_passwordError == null) {
      return;
    }
    setState(() => _passwordError = null);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearUsernameError);
    _passwordController.removeListener(_clearPasswordError);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String username) {
    if (username.isEmpty) {
      return ForgotPasswordPageController.emptyUsernameMessage;
    }
    if (!ForgotPasswordPageController.isValidUsername(username)) {
      return ForgotPasswordPageController.invalidUsernameMessage;
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return ForgotPasswordPageController.emptyPasswordMessage;
    }
    if (!ForgotPasswordPageController.isValidPassword(password)) {
      return ForgotPasswordPageController.weakPasswordMessage;
    }
    return null;
  }

  Future<void> _submitResetPassword() async {
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
      await createAuthService().resetPassword(
        username: username,
        password: password,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _updated = true;
      });
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        if (error.statusCode == 404 ||
            error.message == AuthServiceException.userNotFoundMessage) {
          _usernameError = ForgotPasswordPageController.userNotFoundMessage;
        } else {
          _formError = ForgotPasswordPageController.requestFailedMessage;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _formError = ForgotPasswordPageController.requestFailedMessage;
      });
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgotPasswordPageController.bgBottom,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ForgotPasswordPageController.bgTop,
              ForgotPasswordPageController.bgMid,
              ForgotPasswordPageController.bgBottom,
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
                      horizontal:
                          ForgotPasswordPageController.horizontalPadding.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: ForgotPasswordPageController.topInset.h,
                        ),
                        const PageBackButton(),
                        SizedBox(
                          height: ForgotPasswordPageController.backToTitleGap.h,
                        ),
                        if (_updated) ...[
                          _buildSuccessContent(context),
                        ] else ...[
                          _buildFormContent(context),
                        ],
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

  Widget _buildFormContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ForgotPasswordPageController.title,
          style: TextStyle(
            fontSize: ForgotPasswordPageController.titleFontSize.sp,
            fontWeight: FontWeight.w600,
            color: ForgotPasswordPageController.titleColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: ForgotPasswordPageController.titleToSubtitleGap.h),
        Text(
          ForgotPasswordPageController.subtitle,
          style: TextStyle(
            fontSize: ForgotPasswordPageController.subtitleFontSize.sp,
            fontWeight: FontWeight.w400,
            color: ForgotPasswordPageController.subtitleColor,
            height: 1.45,
          ),
        ),
        SizedBox(height: ForgotPasswordPageController.subtitleToFormGap.h),
        if (_formError != null) ...[
          Text(
            _formError!,
            style: TextStyle(
              fontSize: ForgotPasswordPageController.errorFontSize.sp,
              fontWeight: FontWeight.w400,
              color: ForgotPasswordPageController.errorTextColor,
              height: 1.3,
            ),
          ),
          SizedBox(height: ForgotPasswordPageController.fieldErrorGap.h),
        ],
        _buildValidatedField(
          errorText: _usernameError,
          field: _buildInputField(
            hint: ForgotPasswordPageController.usernameHint,
            controller: _usernameController,
            hasError: _usernameError != null,
          ),
        ),
        SizedBox(height: ForgotPasswordPageController.inputGap.h),
        _buildValidatedField(
          errorText: _passwordError,
          field: _buildInputField(
            hint: ForgotPasswordPageController.newPasswordHint,
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
                color: ForgotPasswordPageController.hintColor,
              ),
            ),
          ),
        ),
        SizedBox(height: ForgotPasswordPageController.formToButtonGap.h),
        _buildResetButton(context),
        SizedBox(height: ForgotPasswordPageController.buttonToFooterGap.h),
        _buildLogInFooter(context),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_reset_outlined,
          size: 44.sp,
          color: ForgotPasswordPageController.successIconColor,
        ),
        SizedBox(height: 18.h),
        Text(
          ForgotPasswordPageController.successTitle,
          style: TextStyle(
            fontSize: ForgotPasswordPageController.successTitleFontSize.sp,
            fontWeight: FontWeight.w600,
            color: ForgotPasswordPageController.titleColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          ForgotPasswordPageController.successMessage,
          style: TextStyle(
            fontSize: ForgotPasswordPageController.successMessageFontSize.sp,
            fontWeight: FontWeight.w400,
            color: ForgotPasswordPageController.subtitleColor,
            height: 1.45,
          ),
        ),
        SizedBox(height: ForgotPasswordPageController.formToButtonGap.h),
        _buildPrimaryButton(
          label: ForgotPasswordPageController.logIn,
          onTap: _goToLogin,
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
          SizedBox(height: ForgotPasswordPageController.fieldErrorGap.h),
          Text(
            errorText,
            style: TextStyle(
              fontSize: ForgotPasswordPageController.errorFontSize.sp,
              fontWeight: FontWeight.w400,
              color: ForgotPasswordPageController.errorTextColor,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required String hint,
    bool hasError = false,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return AuthFormTextField(
      height: ForgotPasswordPageController.inputHeight,
      hint: hint,
      controller: controller,
      obscureText: obscureText,
      hasError: hasError,
      suffixIcon: suffixIcon,
      useShadow: false,
      backgroundColor: ForgotPasswordPageController.inputBackgroundColor,
      borderColor: ForgotPasswordPageController.inputBorderColor,
      errorBorderColor: ForgotPasswordPageController.inputErrorBorderColor,
      textColor: ForgotPasswordPageController.inputTextColor,
      hintColor: ForgotPasswordPageController.hintColor,
      fontSize: ForgotPasswordPageController.inputFontSize,
      hintFontSize: ForgotPasswordPageController.hintFontSize,
      borderRadius: ForgotPasswordPageController.inputBorderRadius,
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return _buildPrimaryButton(
      label: ForgotPasswordPageController.resetButton,
      onTap: _isSubmitting ? null : _submitResetPassword,
      showLoading: _isSubmitting,
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
    bool showLoading = false,
  }) {
    final borderRadius = BorderRadius.circular(
      ForgotPasswordPageController.buttonBorderRadius.r,
    );

    return Material(
      color: ForgotPasswordPageController.buttonColor,
      elevation: ForgotPasswordPageController.buttonElevation,
      shadowColor: const Color(0xFF4A9E68).withValues(alpha: 0.35),
      borderRadius: borderRadius,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: Colors.white.withValues(alpha: 0.28),
        highlightColor: Colors.white.withValues(alpha: 0.14),
        child: SizedBox(
          width: double.infinity,
          height: ForgotPasswordPageController.buttonHeight.h,
          child: Center(
            child: showLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ForgotPasswordPageController.buttonTextColor,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: ForgotPasswordPageController.buttonFontSize.sp,
                      fontWeight: FontWeight.w700,
                      color: ForgotPasswordPageController.buttonTextColor,
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
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            ForgotPasswordPageController.backToLoginPrefix,
            style: TextStyle(
              fontSize: ForgotPasswordPageController.linkFontSize.sp,
              fontWeight: FontWeight.w500,
              color: ForgotPasswordPageController.footerTextColor,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 10.h, 4.w, 10.h),
              child: Text(
                ForgotPasswordPageController.logIn,
                style: TextStyle(
                  fontSize: ForgotPasswordPageController.linkFontSize.sp,
                  fontWeight: FontWeight.w600,
                  color: ForgotPasswordPageController.linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: ForgotPasswordPageController.linkColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
