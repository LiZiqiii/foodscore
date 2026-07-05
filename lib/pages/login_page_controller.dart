import 'package:flutter/material.dart';

/// FoodScore 登录页控制器：文案、颜色与布局常量。
class LoginPageController {
  LoginPageController._();

  // ---------------------------------------------------------------------------
  // 文案
  // ---------------------------------------------------------------------------

  static const String greeting = 'Hello!';
  static const String appTitle = 'FoodScore';
  static const String emailHint = 'E-mail';
  static const String passwordHint = 'Password';
  static const String loginButton = 'Log in';
  static const String forgetPassword = 'Forget Password?';
  static const String noAccountPrefix = 'Do not have an account? ';
  static const String signUp = 'Sign up';

  // ---------------------------------------------------------------------------
  // 背景色 — 白 → 浅薄荷绿，干净无灰块
  // ---------------------------------------------------------------------------

  static const Color bgTop = Color(0xFFFFFFFF);
  static const Color bgMid = Color(0xFFF4FBF2);
  static const Color bgBottom = Color(0xFFE8F6E4);

  // ---------------------------------------------------------------------------
  // 内容色
  // ---------------------------------------------------------------------------

  static const Color titleGreetingColor = Color(0xFF1B5E32);
  static const Color brandGradientStart = Color(0xFF145A2E);
  static const Color brandGradientEnd = Color(0xFF2E9B52);
  static const Color accentDotColor = Color(0xFF7FCB8F);
  static const Color hintColor = Color(0xFFA8A8A8);
  static const Color inputTextColor = Color(0xFF2C2C2C);
  static const Color inputBackgroundColor = Color(0xFFFFFFFF);
  static const Color inputBorderColor = Color(0xFFDCE8DC);
  static const Color buttonColor = Color(0xFF7FCB8F);
  static const Color buttonTextColor = Color(0xFF134026);
  static const Color linkColor = Color(0xFF6BAF7E);
  static const Color footerTextColor = Color(0xFF757575);

  // ---------------------------------------------------------------------------
  // 字体
  // ---------------------------------------------------------------------------

  static const double greetingFontSize = 36;
  static const double brandFontSize = 44;
  static const double inputFontSize = 15;
  static const double hintFontSize = 15;
  static const double buttonFontSize = 17;
  static const double linkFontSize = 15;

  // ---------------------------------------------------------------------------
  // 布局
  // ---------------------------------------------------------------------------

  static const double horizontalPadding = 28;
  static const double topInset = 44;
  static const double titleToFormGap = 36;
  static const double inputGap = 12;
  static const double formToButtonGap = 24;
  static const double buttonToForgetGap = 28;
  static const double forgetToSignUpGap = 18;

  static const double formWidthRatio = 0.8;
  static const double inputHeight = 46;
  static const double inputBorderRadius = 12;
  static const double buttonWidth = 230;
  static const double buttonHeight = 50;
  static const double buttonBorderRadius = 14;
  static const double buttonElevation = 4;
}
