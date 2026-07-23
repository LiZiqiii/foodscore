import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';

import 'forgot_password_page_controller.dart';
import 'login_page.dart';
import '../widgets/page_back_button.dart';

/// 忘记密码页：输入邮箱发送重置链接（无后端时为本地确认态）。
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearEmailError);
  }

  void _clearEmailError() {
    if (_emailError == null) {
      return;
    }
    setState(() => _emailError = null);
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearEmailError);
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return ForgotPasswordPageController.emptyEmailMessage;
    }
    if (!ForgotPasswordPageController.isValidEmail(email)) {
      return ForgotPasswordPageController.invalidEmailMessage;
    }
    return null;
  }

  void _submitResetLink() {
    final email = _emailController.text.trim();
    final emailError = _validateEmail(email);

    setState(() {
      _emailError = emailError;
    });

    if (emailError != null) {
      return;
    }

    setState(() => _sent = true);
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
                        if (_sent) ...[
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
        _buildValidatedField(
          errorText: _emailError,
          field: _buildInputField(
            hint: ForgotPasswordPageController.emailHint,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hasError: _emailError != null,
          ),
        ),
        SizedBox(height: ForgotPasswordPageController.formToButtonGap.h),
        _buildSendButton(context),
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
          Icons.mark_email_read_outlined,
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
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    final borderRadius = BorderRadius.circular(
      ForgotPasswordPageController.inputBorderRadius.r,
    );
    final borderColor = hasError
        ? ForgotPasswordPageController.inputErrorBorderColor
        : ForgotPasswordPageController.inputBorderColor;

    return Container(
      height: ForgotPasswordPageController.inputHeight.h,
      decoration: BoxDecoration(
        color: ForgotPasswordPageController.inputBackgroundColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: ForgotPasswordPageController.inputFontSize.sp,
          fontWeight: FontWeight.w500,
          color: ForgotPasswordPageController.inputTextColor,
          height: 1.0,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: ForgotPasswordPageController.hintFontSize.sp,
            fontWeight: FontWeight.w400,
            color: ForgotPasswordPageController.hintColor,
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

  Widget _buildSendButton(BuildContext context) {
    return _buildPrimaryButton(
      label: ForgotPasswordPageController.sendButton,
      onTap: _submitResetLink,
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
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
            child: Text(
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
