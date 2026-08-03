import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import 'food_score_home_page.dart';
import 'forgot_password_page.dart';
import 'login_page_controller.dart';
import 'sign_up_page.dart';
import 'sign_up_page_controller.dart';
import '../services/auth_service.dart';
import '../services/auth_service_factory.dart';
import '../services/auth_session.dart';
import '../services/weekly_reflection_store.dart';
import '../services/weekly_reflection_summary_cache.dart';
import '../widgets/app_spot_illustration.dart';
import '../widgets/auth_form_text_field.dart';

/// FoodScore 登录页。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.registrationSuccess = false});

  /// 从注册页跳转过来时为 true，用于显示成功提示。
  final bool registrationSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  String? _formError;

  bool _showRegistrationBanner = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_clearUsernameError);
    _passwordController.addListener(_clearPasswordError);
    _showRegistrationBanner = widget.registrationSuccess;
  }

  void _dismissRegistrationBanner() {
    if (!_showRegistrationBanner) {
      return;
    }
    setState(() => _showRegistrationBanner = false);
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
    super.dispose();
  }

  String? _validateUsername(String username) {
    if (username.isEmpty) {
      return LoginPageController.emptyUsernameMessage;
    }
    if (!LoginPageController.isValidUsername(username)) {
      return LoginPageController.invalidUsernameMessage;
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return LoginPageController.emptyPasswordMessage;
    }
    return null;
  }

  Future<void> _submitLogin() async {
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
      final user = await createAuthService().login(
        username: username,
        password: password,
      );

      if (!mounted) {
        return;
      }

      AuthSession.instance.setUser(user);
      WeeklyReflectionStore.instance.clear();
      WeeklyReflectionSummaryCache.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const FoodScoreHomePage(),
        ),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        if (error.statusCode == 401) {
          _passwordError = LoginPageController.invalidLoginMessage;
        } else {
          _formError = LoginPageController.requestFailedMessage;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _formError = LoginPageController.requestFailedMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double formWidth =
        context.screenWidth * LoginPageController.formWidthRatio;

    return Scaffold(
      backgroundColor: LoginPageController.bgBottom,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              LoginPageController.bgTop,
              LoginPageController.bgMid,
              LoginPageController.bgBottom,
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SizedBox.expand(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: LoginPageController.horizontalPadding.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: LoginPageController.topInset.h),
                          if (_showRegistrationBanner) ...[
                            _buildRegistrationSuccessBanner(),
                            SizedBox(height: 16.h),
                          ],
                          _buildTitleSection(),
                          SizedBox(
                            height: LoginPageController.titleToFormGap.h,
                          ),
                          _buildFormBlock(context, formWidth),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationSuccessBanner() {
    return Material(
      color: LoginPageController.bgMid,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _dismissRegistrationBanner,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 10.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpotIllustration(
                kind: AppSpotIllustrationKind.registrationSuccess,
                size: 56,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  SignUpPageController.registrationSuccessMessage,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: LoginPageController.titleGreetingColor,
                    height: 1.35,
                  ),
                ),
              ),
              Icon(
                Icons.close_rounded,
                size: 20.sp,
                color: LoginPageController.taglineColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LoginPageController.greeting,
          style: TextStyle(
            fontSize: LoginPageController.greetingFontSize.sp,
            fontWeight: FontWeight.w600,
            color: LoginPageController.titleGreetingColor,
            height: 1.15,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: LoginPageController.greetingToBrandGap.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBrandAccent(),
            SizedBox(width: 10.w),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      LoginPageController.brandGradientStart,
                      LoginPageController.brandGradientEnd,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    LoginPageController.appTitle,
                    softWrap: false,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: LoginPageController.brandFontSize.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: LoginPageController.brandToTaglineGap.h),
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Text(
            LoginPageController.tagline,
            style: TextStyle(
              fontSize: LoginPageController.taglineFontSize.sp,
              fontWeight: FontWeight.w400,
              color: LoginPageController.taglineColor,
              height: 1.5,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandAccent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: LoginPageController.accentDotColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: LoginPageController.accentDotColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: LoginPageController.accentDotColor,
            ),
          ),
          SizedBox(width: 5.w),
          Icon(
            Icons.eco_outlined,
            size: 14.sp,
            color: LoginPageController.brandGradientEnd,
          ),
        ],
      ),
    );
  }

  Widget _buildFormBlock(BuildContext context, double formWidth) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: formWidth,
        child: Column(
          children: [
            _buildValidatedField(
              errorText: _usernameError,
              field: _buildInputField(
                hint: LoginPageController.usernameHint,
                controller: _usernameController,
                hasError: _usernameError != null,
              ),
            ),
            SizedBox(height: LoginPageController.inputGap.h),
            _buildValidatedField(
              errorText: _passwordError,
              field: _buildInputField(
                hint: LoginPageController.passwordHint,
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
                    color: LoginPageController.hintColor,
                  ),
                ),
              ),
            ),
            if (_formError != null) ...[
              SizedBox(height: LoginPageController.fieldErrorGap.h),
              Text(
                _formError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: LoginPageController.errorFontSize.sp,
                  fontWeight: FontWeight.w400,
                  color: LoginPageController.errorTextColor,
                  height: 1.3,
                ),
              ),
            ],
            SizedBox(height: LoginPageController.formToButtonGap.h),
            _buildLoginButton(context),
            SizedBox(height: LoginPageController.buttonToForgetGap.h),
            _buildForgetPasswordLink(),
            SizedBox(height: LoginPageController.forgetToSignUpGap.h),
            _buildSignUpFooter(context),
          ],
        ),
      ),
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
          SizedBox(height: LoginPageController.fieldErrorGap.h),
          Text(
            errorText,
            style: TextStyle(
              fontSize: LoginPageController.errorFontSize.sp,
              fontWeight: FontWeight.w400,
              color: LoginPageController.errorTextColor,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required String hint,
    bool obscureText = false,
    bool hasError = false,
    TextEditingController? controller,
    Widget? suffixIcon,
  }) {
    return AuthFormTextField(
      height: LoginPageController.inputHeight,
      hint: hint,
      controller: controller,
      obscureText: obscureText,
      enabled: !_isSubmitting,
      hasError: hasError,
      suffixIcon: suffixIcon,
      backgroundColor: LoginPageController.inputBackgroundColor,
      borderColor: LoginPageController.inputBorderColor,
      errorBorderColor: LoginPageController.inputErrorBorderColor,
      textColor: LoginPageController.inputTextColor,
      hintColor: LoginPageController.hintColor,
      fontSize: LoginPageController.inputFontSize,
      hintFontSize: LoginPageController.hintFontSize,
      borderRadius: LoginPageController.inputBorderRadius,
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      LoginPageController.buttonBorderRadius.r,
    );

    return Center(
      child: Material(
        color: _isSubmitting
            ? LoginPageController.buttonColor.withValues(alpha: 0.7)
            : LoginPageController.buttonColor,
        elevation: LoginPageController.buttonElevation,
        shadowColor: const Color(0xFF4A9E68).withValues(alpha: 0.35),
        borderRadius: borderRadius,
        clipBehavior: Clip.none,
        child: InkWell(
          onTap: _isSubmitting ? null : _submitLogin,
          borderRadius: borderRadius,
          splashColor: Colors.white.withValues(alpha: 0.28),
          highlightColor: Colors.white.withValues(alpha: 0.14),
          child: SizedBox(
            width: LoginPageController.buttonWidth.w,
            height: LoginPageController.buttonHeight.h,
            child: Center(
              child: _isSubmitting
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: LoginPageController.buttonTextColor,
                      ),
                    )
                  : Text(
                      LoginPageController.loginButton,
                      style: TextStyle(
                        fontSize: LoginPageController.buttonFontSize.sp,
                        fontWeight: FontWeight.w700,
                        color: LoginPageController.buttonTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgetPasswordLink() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ForgotPasswordPage(),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Text(
          LoginPageController.forgetPassword,
          style: TextStyle(
            fontSize: LoginPageController.linkFontSize.sp,
            fontWeight: FontWeight.w500,
            color: LoginPageController.linkColor,
            decoration: TextDecoration.underline,
            decorationColor: LoginPageController.linkColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpFooter(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            LoginPageController.noAccountPrefix,
            style: TextStyle(
              fontSize: LoginPageController.linkFontSize.sp,
              fontWeight: FontWeight.w500,
              color: LoginPageController.footerTextColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SignUpPage(),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 10.h, 4.w, 10.h),
              child: Text(
                LoginPageController.signUp,
                style: TextStyle(
                  fontSize: LoginPageController.linkFontSize.sp,
                  fontWeight: FontWeight.w600,
                  color: LoginPageController.linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: LoginPageController.linkColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
