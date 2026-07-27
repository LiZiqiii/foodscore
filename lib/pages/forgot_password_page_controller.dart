import 'package:flutter/material.dart';

/// 忘记密码页文案、颜色与布局常量。
class ForgotPasswordPageController {
  ForgotPasswordPageController._();

  static const String title = 'Forgot password?';
  static const String subtitle =
      'Enter your username and new password.';
  static const String usernameHint = 'Username';
  static const String newPasswordHint = 'New password';
  static const String resetButton = 'Reset password';

  static const String successTitle = 'Password updated';
  static const String successMessage =
      'Your password has been updated. You can log in with your new password.';

  static const String emptyUsernameMessage = 'Please enter a username.';
  static const String invalidUsernameMessage =
      'Username must be 1–50 characters.';
  static const String emptyPasswordMessage = 'Please enter a new password.';
  static const String weakPasswordMessage =
      'Password must be at least 8 characters.';

  static const String backToLoginPrefix = 'Remember your password? ';
  static const String logIn = 'Log in';

  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 50;

  static const Color bgTop = Color(0xFFFFFFFF);
  static const Color bgMid = Color(0xFFF4FBF2);
  static const Color bgBottom = Color(0xFFE8F6E4);

  static const Color titleColor = Color(0xFF1B5E32);
  static const Color subtitleColor = Color(0xFF6E7268);
  static const Color hintColor = Color(0xFFA8A8A8);
  static const Color inputTextColor = Color(0xFF2C2C2C);
  static const Color inputBackgroundColor = Color(0xFFFFFFFF);
  static const Color inputBorderColor = Color(0xFFDCE8DC);
  static const Color inputErrorBorderColor = Color(0xFFE57373);
  static const Color errorTextColor = Color(0xFFC62828);
  static const Color buttonColor = Color(0xFF7FCB8F);
  static const Color buttonTextColor = Color(0xFF134026);
  static const Color linkColor = Color(0xFF6BAF7E);
  static const Color footerTextColor = Color(0xFF757575);
  static const Color successIconColor = Color(0xFF2E9B52);

  static const double horizontalPadding = 28;
  static const double topInset = 16;
  static const double backToTitleGap = 20;
  static const double titleFontSize = 26;
  static const double subtitleFontSize = 14;
  static const double inputFontSize = 15;
  static const double hintFontSize = 15;
  static const double buttonFontSize = 17;
  static const double linkFontSize = 15;
  static const double errorFontSize = 12;
  static const double successTitleFontSize = 22;
  static const double successMessageFontSize = 14;

  static const double titleToSubtitleGap = 10;
  static const double subtitleToFormGap = 22;
  static const double inputGap = 12;
  static const double fieldErrorGap = 6;
  static const double formToButtonGap = 26;
  static const double buttonToFooterGap = 20;

  static const double inputHeight = 40;
  static const double inputBorderRadius = 12;
  static const double buttonHeight = 50;
  static const double buttonBorderRadius = 14;
  static const double buttonElevation = 4;

  static bool isValidUsername(String username) {
    final trimmed = username.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxUsernameLength;
  }

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }
}
