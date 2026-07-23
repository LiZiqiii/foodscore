import 'package:flutter/material.dart';

/// 注册页文案、颜色与布局常量。
class SignUpPageController {
  SignUpPageController._();

  static const String title = 'Create your account';

  static const String emailHint = 'E-mail';
  static const String passwordHint = 'Password';

  static const String coachingLabel = 'Coaching (optional)';
  static const String heightHint = 'Height cm';
  static const String weightHint = 'Weight kg';

  static const String healthDiabetes = 'Diabetes';
  static const String healthHypertension = 'Hypertension';
  static const String healthOther = 'Other';

  static const List<String> healthOptions = [
    healthDiabetes,
    healthHypertension,
    healthOther,
  ];

  static const String otherHealthHint = 'Brief note, e.g. high cholesterol';
  static const int otherHealthMaxLength = 48;

  static const int minPasswordLength = 8;

  static const String emptyEmailMessage = 'Please enter your e-mail.';
  static const String invalidEmailMessage = 'Please enter a valid e-mail.';
  static const String emptyPasswordMessage = 'Please enter a password.';
  static const String weakPasswordMessage =
      'Password must be at least 8 characters.';

  static const String createAccountButton = 'Create account';
  static const String hasAccountPrefix = 'Already have an account? ';
  static const String logIn = 'Log in';

  static const Color bgTop = Color(0xFFFFFFFF);
  static const Color bgMid = Color(0xFFF4FBF2);
  static const Color bgBottom = Color(0xFFE8F6E4);

  static const Color titleColor = Color(0xFF1B5E32);
  static const Color sectionTitleColor = Color(0xFF4A4B48);
  static const Color hintColor = Color(0xFFA8A8A8);
  static const Color inputTextColor = Color(0xFF2C2C2C);
  static const Color inputBackgroundColor = Color(0xFFFFFFFF);
  static const Color inputBorderColor = Color(0xFFDCE8DC);
  static const Color inputErrorBorderColor = Color(0xFFE57373);
  static const Color errorTextColor = Color(0xFFC62828);
  static const Color chipBg = Color(0xFFE1F4F0);
  static const Color chipBgSelected = Color(0xFF1A6731);
  static const Color chipText = Color(0xFF3D6C47);
  static const Color chipTextSelected = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFF7FCB8F);
  static const Color buttonTextColor = Color(0xFF134026);
  static const Color linkColor = Color(0xFF6BAF7E);
  static const Color footerTextColor = Color(0xFF757575);

  static const double horizontalPadding = 28;
  static const double topInset = 16;
  static const double backToTitleGap = 20;
  static const double titleFontSize = 26;
  static const double sectionTitleFontSize = 14;
  static const double inputFontSize = 15;
  static const double hintFontSize = 15;
  static const double buttonFontSize = 17;
  static const double linkFontSize = 15;
  static const double errorFontSize = 12;
  static const double chipFontSize = 13;

  static const double titleToFormGap = 22;
  static const double inputGap = 12;
  static const double fieldErrorGap = 6;
  static const double sectionGap = 22;
  static const double coachingLabelGap = 12;
  static const double metricsGap = 10;
  static const double chipGap = 8;
  static const double otherFieldGap = 10;
  static const double formToButtonGap = 26;
  static const double buttonToFooterGap = 20;

  static const double inputHeight = 46;
  static const double inputBorderRadius = 12;
  static const double buttonHeight = 50;
  static const double buttonBorderRadius = 14;
  static const double buttonElevation = 4;
  static const double chipHeight = 32;

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }
}
