import 'package:flutter/material.dart';

class AppColors {
  // ─── Dark UI + Neon Purple Design Tokens (A507) ───
  static const Color bgPrimary = Color(0xFF100D1D);
  static const Color bgSecondary = Color(0xFF1C1730);
  static const Color surface = Color(0xFF30234A);
  static const Color primaryPurple = Color(0xFFA94DFF);
  static const Color neonLavender = Color(0xFFD68AFF);
  static const Color lightPink = Color(0xFFF3B8FF);

  // Text
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFD5CDE5);
  static const Color hintCaption = Color(0xFF9288A7);
  static const Color disabledText = Color(0xFF655D78);
  static const Color textPrimary = primaryText;
  static const Color textSecondary = secondaryText;
  static const Color textHint = hintCaption;
  static const Color textDisabled = disabledText;

  // Borders, Shadows & Dividers
  static const Color borderDefault = Color(0xFF423454);
  static const Color borderActive = Color(0xFFB65CFF);
  static const Color neonShadow = Color(0xFFA94DFF);
  static const Color divider = Color(0xFF332A43);
  static const Color overlay = Color(0x99080611); // 60% of #080611

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8C38F5), Color(0xFFC05CFF), Color(0xFFE18BFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF8C38F5), Color(0xFFC05CFF), Color(0xFFE18BFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF100D1D), Color(0xFF241638), Color(0xFF351D4B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF39234F), Color(0xFF21182F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient activeTabGradient = LinearGradient(
    colors: [Color(0xFF8C38F5), Color(0xFFC05CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Legacy Mappings for Backward Compatibility ───
  static const Color backgroundColor = bgPrimary;
  static const Color backgroundItemColor = bgSecondary;
  static const Color secondColor = bgSecondary;
  static const Color cardColor = bgSecondary;
  static const Color colorBgAds = bgSecondary;

  static const Color gradientStart = Color(0xFF8C38F5);
  static const Color gradientEnd = Color(0xFFE18BFF);
  static const Color main = primaryPurple;
  static const Color secondary = neonLavender;
  static const Color tertiary = lightPink;
  static const Color colorPrimary = primaryPurple;

  static const Color textColor = primaryText;
  static const Color whiteText = primaryText;
  static const Color textSubColor = secondaryText;
  static const Color grayText = hintCaption;
  static const Color blackText = Color(0xFF100D1D);

  static const Color gray = Color(0xFF1C1730);
  static const Color gray1 = disabledText;
  static const Color gray2 = Color(0xFF423454);

  static const Color redPrimary = Color(0xFFFF4B6E);
  static const Color greenPrimary = Color(0xFF58BD7D);
  static const Color greenSecondary = Color(0xFF00C9BF);
  static const Color yellowPrimary = Color(0xFFFFB800);
  static const Color yellowBorder = Color(0xFFFFD159);
  static const Color blueSecondary = Color(0xFF30234A);
  static const Color blueThird = Color(0xFFD68AFF);
  static Color borderColor = borderDefault;

  static const Color bgInput = bgSecondary;
  static const Color bgColor = bgPrimary;
  static const Color bgTabColor = surface;
  static const Color colorGradientButtonStart = Color(0xFF8C38F5);
  static const Color colorGradientButtonEnd = Color(0xFFE18BFF);
  static const Color colorAppBarBlue = bgSecondary;
  static const Color colorBgRelationship = surface;

  static const Color textMain = primaryText;
  static const Color textSub = secondaryText;
  static const Color textSub1 = secondaryText;
  static const Color iconGray = hintCaption;
  static const Color transparent = Colors.transparent;

  static const Color dividerColor = divider;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color statusBarColor = bgPrimary;
  static const Color appBarColor = bgPrimary;
  static const Color appBarIconColor = primaryText;
  static const Color appBarTextColor = primaryText;

  static const Color centerTextColor = hintCaption;
  static const MaterialColor colorPrimarySwatch = Colors.purple;

  static const Color colorAccent = primaryPurple;
  static const Color colorLightGreen = Color(0xFF00EFA7);
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color lightGreyColor = hintCaption;
  static const Color errorColor = Color(0xFFFF4B6E);
  static const Color colorDark = bgPrimary;

  static const Color adsCTABackground = primaryPurple;
  static const Color adsNativeBorderColor = borderDefault;

  static const Color buttonBgColor = colorPrimary;
  static const Color disabledButtonBgColor = disabledText;
  static const Color defaultRippleColor = Color(0x1FA94DFF);

  static const Color textColorPrimary = primaryText;
  static const Color textColorSecondary = secondaryText;
  static const Color textColorTag = primaryPurple;
  static const Color textColorGreyLight = secondaryText;
  static const Color textColorGreyDark = hintCaption;
  static const Color textColorBlueGreyDark = hintCaption;
  static const Color textColorCyan = primaryPurple;
  static const Color textColorWhite = primaryText;
  static Color searchFieldTextColor = hintCaption;

  static const Color iconColorDefault = hintCaption;
  static Color barrierColor = overlay;
  static Color timelineDividerColor = divider;

  static const Color gradientStartColor = Colors.black87;
  static const Color gradientEndColor = Colors.transparent;
  static const Color silverAppBarOverlayColor = Color(0x80100D1D);

  static const Color switchActiveColor = primaryPurple;
  static const Color switchInactiveColor = disabledText;
  static Color elevatedContainerColorOpacity = surface;
  static const Color suffixImageColor = hintCaption;

  static const Color monthColor = neonLavender;
  static const Color baseColor = surface;
  static const Color highlightColor = borderDefault;

  static Color hexToColor(String hex) {
    assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
        'hex color must be #rrggbb or #rrggbbaa');

    return Color(
      int.parse(hex.substring(1), radix: 16) +
          (hex.length == 7 ? 0xff000000 : 0x00000000),
    );
  }
}
