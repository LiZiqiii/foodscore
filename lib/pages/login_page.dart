import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import 'food_score_home_page.dart';
import 'forgot_password_page.dart';
import 'login_page_controller.dart';
import 'sign_up_page.dart';

/// FoodScore 登录页。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

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
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    LoginPageController.brandGradientStart,
                    LoginPageController.brandGradientEnd,
                  ],
                ).createShader(bounds),
                child: Text(
                  LoginPageController.appTitle,
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
            _buildInputField(hint: LoginPageController.emailHint),
            SizedBox(height: LoginPageController.inputGap.h),
            _buildInputField(
              hint: LoginPageController.passwordHint,
              obscureText: _obscurePassword,
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

  Widget _buildInputField({
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final borderRadius = BorderRadius.circular(
      LoginPageController.inputBorderRadius.r,
    );

    return Container(
      height: LoginPageController.inputHeight.h,
      decoration: BoxDecoration(
        color: LoginPageController.inputBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: LoginPageController.inputBorderColor,
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
      padding: EdgeInsets.only(left: 16.w, right: suffixIcon == null ? 16.w : 4.w),
      child: TextField(
        obscureText: obscureText,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: LoginPageController.inputFontSize.sp,
          fontWeight: FontWeight.w500,
          color: LoginPageController.inputTextColor,
          height: 1.0,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: LoginPageController.hintFontSize.sp,
            fontWeight: FontWeight.w400,
            color: LoginPageController.hintColor,
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

  Widget _buildLoginButton(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      LoginPageController.buttonBorderRadius.r,
    );

    return Center(
      child: Material(
        color: LoginPageController.buttonColor,
        elevation: LoginPageController.buttonElevation,
        shadowColor: const Color(0xFF4A9E68).withValues(alpha: 0.35),
        borderRadius: borderRadius,
        clipBehavior: Clip.none,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const FoodScoreHomePage(),
              ),
            );
          },
          borderRadius: borderRadius,
          splashColor: Colors.white.withValues(alpha: 0.28),
          highlightColor: Colors.white.withValues(alpha: 0.14),
          child: SizedBox(
            width: LoginPageController.buttonWidth.w,
            height: LoginPageController.buttonHeight.h,
            child: Center(
              child: Text(
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
