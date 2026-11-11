import 'dart:async';
import 'package:cscmobi_app/screens/onboard/onboard_controller.dart';
import 'package:cscmobi_app/screens/onboard/onboard_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/base/base_controller.dart';
import '../../core/utils/app_util.dart';
import '../../helper/firebase_helper.dart';
import '../../helper/firebase_remote_config_service.dart';
import '../../models/language_model.dart';
import '../../routes/app_pages.dart';
import '../../utils/app_setting.dart';
import '../home/home_controller.dart';
import '../chats/chats_controller.dart';
import '../chat_detail/chat_detail_controller.dart';
import '../setting/setting_controller.dart';

class LanguageController extends BaseController {
  static const List<LanguageGroupModel> supportedGroups = [
    LanguageGroupModel(
      groupId: 'hi',
      title: 'हिन्दी',
      nativeName: 'Hindi',
      languageCode: 'hi',
      singleCountryCode: 'in',
      pngAsset: 'assets/flag/flag_hindi.png',
    ),
    LanguageGroupModel(
      groupId: 'bn',
      title: 'বাংলা',
      nativeName: 'Bengali',
      languageCode: 'bn',
      singleCountryCode: 'bd',
      pngAsset: 'assets/flag/flag_bengali.png',
    ),
    LanguageGroupModel(
      groupId: 'id',
      title: 'Bahasa Indonesia',
      nativeName: 'Indonesian',
      languageCode: 'id',
      singleCountryCode: 'id',
      pngAsset: 'assets/flag/flag_indonesia.png',
    ),
    LanguageGroupModel(
      groupId: 'en',
      title: 'English',
      nativeName: 'English',
      languageCode: 'en',
      pngAsset: 'assets/flag/flag_english.png',
      variants: [
        LanguageVariantModel(
          variantId: 'en_US',
          title: 'English (US)',
          nativeName: 'English',
          languageCode: 'en',
          countryCode: 'us',
          pngAsset: 'assets/flag/flag_english.png',
        ),
        LanguageVariantModel(
          variantId: 'en_GB',
          title: 'English (UK)',
          nativeName: 'English',
          languageCode: 'en',
          countryCode: 'gb',
        ),
        LanguageVariantModel(
          variantId: 'en_IN',
          title: 'English (India)',
          nativeName: 'English',
          languageCode: 'en',
          countryCode: 'in',
          pngAsset: 'assets/flag/flag_hindi.png',
        ),
      ],
    ),
    LanguageGroupModel(
      groupId: 'fil',
      title: 'Filipino',
      nativeName: 'Filipino',
      languageCode: 'fil',
      singleCountryCode: 'ph',
      pngAsset: 'assets/flag/flag_philippine.png',
    ),
    LanguageGroupModel(
      groupId: 'es',
      title: 'Español',
      nativeName: 'Spanish',
      languageCode: 'es',
      pngAsset: 'assets/flag/flag_spain.png',
      variants: [
        LanguageVariantModel(
          variantId: 'es_ES',
          title: 'Español (España)',
          nativeName: 'Spanish (Spain)',
          languageCode: 'es',
          countryCode: 'es',
          pngAsset: 'assets/flag/flag_spain.png',
        ),
        LanguageVariantModel(
          variantId: 'es_MX',
          title: 'Español (México)',
          nativeName: 'Spanish (Mexico)',
          languageCode: 'es',
          countryCode: 'mx',
        ),
        LanguageVariantModel(
          variantId: 'es_AR',
          title: 'Español (Argentina)',
          nativeName: 'Spanish (Argentina)',
          languageCode: 'es',
          countryCode: 'ar',
        ),
      ],
    ),
    LanguageGroupModel(
      groupId: 'tr',
      title: 'Türkçe',
      nativeName: 'Turkish',
      languageCode: 'tr',
      singleCountryCode: 'tr',
      pngAsset: 'assets/flag/flag_turkish.png',
    ),
    LanguageGroupModel(
      groupId: 'pt',
      title: 'Português',
      nativeName: 'Portuguese',
      languageCode: 'pt',
      pngAsset: 'assets/flag/flag_portuguese.png',
      variants: [
        LanguageVariantModel(
          variantId: 'pt_BR',
          title: 'Português (Brasil)',
          nativeName: 'Portuguese (Brazil)',
          languageCode: 'pt',
          countryCode: 'br',
        ),
        LanguageVariantModel(
          variantId: 'pt_PT',
          title: 'Português (Portugal)',
          nativeName: 'Portuguese (Portugal)',
          languageCode: 'pt',
          countryCode: 'pt',
          pngAsset: 'assets/flag/flag_portuguese.png',
        ),
      ],
    ),
    LanguageGroupModel(
      groupId: 'ar',
      title: 'العربية',
      nativeName: 'Arabic',
      languageCode: 'ar',
      pngAsset: 'assets/flag/flag_arabic.png',
      variants: [
        LanguageVariantModel(
          variantId: 'ar_SA',
          title: 'العربية (السعودية)',
          nativeName: 'Arabic (Saudi Arabia)',
          languageCode: 'ar',
          countryCode: 'sa',
          pngAsset: 'assets/flag/flag_arabic.png',
        ),
        LanguageVariantModel(
          variantId: 'ar_EG',
          title: 'العربية (مصر)',
          nativeName: 'Arabic (Egypt)',
          languageCode: 'ar',
          countryCode: 'eg',
        ),
        LanguageVariantModel(
          variantId: 'ar_AE',
          title: 'العربية (الإمارات)',
          nativeName: 'Arabic (UAE)',
          languageCode: 'ar',
          countryCode: 'ae',
        ),
      ],
    ),
    LanguageGroupModel(
      groupId: 'ru',
      title: 'Русский',
      nativeName: 'Russian',
      languageCode: 'ru',
      singleCountryCode: 'ru',
      pngAsset: 'assets/flag/flag_russia.png',
    ),
    LanguageGroupModel(
      groupId: 'fr',
      title: 'Français',
      nativeName: 'French',
      languageCode: 'fr',
      singleCountryCode: 'fr',
      pngAsset: 'assets/flag/flag_france.png',
    ),
    LanguageGroupModel(
      groupId: 'de',
      title: 'Deutsch',
      nativeName: 'German',
      languageCode: 'de',
      singleCountryCode: 'de',
      pngAsset: 'assets/flag/flag_german.png',
    ),
    LanguageGroupModel(
      groupId: 'it',
      title: 'Italiano',
      nativeName: 'Italian',
      languageCode: 'it',
      singleCountryCode: 'it',
      pngAsset: 'assets/flag/flag_italy.png',
    ),
    LanguageGroupModel(
      groupId: 'ko',
      title: '한국어',
      nativeName: 'Korean',
      languageCode: 'ko',
      singleCountryCode: 'kr',
      pngAsset: 'assets/flag/flag_korea.png',
    ),
    LanguageGroupModel(
      groupId: 'ja',
      title: '日本語',
      nativeName: 'Japanese',
      languageCode: 'ja',
      singleCountryCode: 'jp',
      pngAsset: 'assets/flag/flag_japan.png',
    ),
    LanguageGroupModel(
      groupId: 'vi',
      title: 'Tiếng Việt',
      nativeName: 'Vietnamese',
      languageCode: 'vi',
      singleCountryCode: 'vn',
      pngAsset: 'assets/flag/flag_vietnam.png',
    ),
  ];

  final RxList<LanguageModel> availableLanguages = RxList();
  final RxList<LanguageGroupModel> groups = RxList();
  Rx<LanguageModel>? currentChosenLang;

  final RxBool isFirstLaunchFlow = false.obs;
  final RxInt selectedLangPosition = 100.obs;
  final RxBool isSecondaryAdActive = false.obs;
  final RxBool canShowProceedButton = false.obs;
  final RxBool isLanguageLoading = false.obs;

  final RxnString expandedGroupId = RxnString();
  final RxnString selectedLanguageCode = RxnString();
  final RxnString selectedVariantId = RxnString();
  final RxBool showEnglishHandHint = true.obs;

  Timer? _nextDelayTimer;
  Timer? _loadingTimer;

  // Aliases for compatibility
  RxList<LanguageModel> get itemsList => availableLanguages;
  RxBool get isFirstLaunch => isFirstLaunchFlow;
  RxInt get selectedIndex => selectedLangPosition;
  RxBool get isShowAltAds => isSecondaryAdActive;
  RxBool get isShouldShowNext => canShowProceedButton;
  RxBool get isLoading => isLanguageLoading;

  bool get hasSelection =>
      selectedLanguageCode.value != null && selectedVariantId.value != null;

  bool get isPrimaryLangAdEnabled =>
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language) ||
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language_high);

  bool get isSecondaryLangAdEnabled =>
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language_alt) ||
      FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.native_language_high_alt);

  bool get showNativeLanguage => isPrimaryLangAdEnabled;
  bool get showNativeLanguageAlt => isSecondaryLangAdEnabled;

  @override
  void onInit() {
    super.onInit();
    FirebaseHelper.setTrackingScreenName("LanguageScreen");
    if (Get.arguments != null) {
      AppUtil.showLogFull(
          "LanguageController onInit Get.arguments: ${Get.arguments}");
      isFirstLaunchFlow.value = Get.arguments["isFirstLaunch"] ?? false;
    } else {
      AppUtil.showLogFull("LanguageController onInit NO ARGUMENTS");
    }
    _populateSupportedLanguages();

    expandedGroupId.value = null;
    showEnglishHandHint.value = true;

    if (!isFirstLaunchFlow.value) {
      restoreSavedLanguage();
      isLanguageLoading.value = false;
      return;
    }

    selectedLanguageCode.value = null;
    selectedVariantId.value = null;
    selectedLangPosition.value = 100;

    isLanguageLoading.value = true;
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 3), () {
      isLanguageLoading.value = false;
    });
  }

  void _populateSupportedLanguages() {
    groups
      ..clear()
      ..addAll(supportedGroups);

    availableLanguages.clear();
    for (final group in supportedGroups) {
      availableLanguages.add(
        LanguageModel(
          pngAsset: group.pngAsset ?? 'assets/flag/flag_english.png',
          title: group.nativeName,
          languageCode: group.languageCode,
          nativeName: group.title,
        ),
      );
    }
  }

  void onToggleDropdownGroup(LanguageGroupModel group) {
    if (isLanguageLoading.value) return;
    showEnglishHandHint.value = false;
    if (expandedGroupId.value == group.groupId) {
      expandedGroupId.value = null;
    } else {
      expandedGroupId.value = group.groupId;
    }
  }

  void onSelectSingleGroup(LanguageGroupModel group) {
    if (isLanguageLoading.value) return;
    showEnglishHandHint.value = false;
    _applySelection(
      langCode: group.languageCode,
      variantId: group.groupId,
    );
  }

  void onSelectVariant(LanguageVariantModel variant) {
    if (isLanguageLoading.value) return;
    showEnglishHandHint.value = false;
    _applySelection(
      langCode: variant.languageCode,
      variantId: variant.variantId,
    );
  }

  void _applySelection({
    required String langCode,
    required String variantId,
  }) {
    selectedLanguageCode.value = langCode;
    selectedVariantId.value = variantId;

    final int groupIdx = groups.indexWhere((g) => g.languageCode == langCode);
    if (groupIdx >= 0) {
      selectedLangPosition.value = groupIdx;
    }

    if (!isFirstLaunchFlow.value) {
      canShowProceedButton.value = true;
      return;
    }

    if (!isSecondaryAdActive.value && isFirstLaunchFlow.value) {
      FirebaseHelper.logEventName(
        FirebaseHelper.language_next_view,
        param: Get.currentRoute,
      );
    }

    if (isSecondaryAdActive.value) {
      canShowProceedButton.value = true;
      return;
    }

    isSecondaryAdActive.value = true;
    canShowProceedButton.value = false;
    _nextDelayTimer?.cancel();
    _nextDelayTimer = Timer(const Duration(milliseconds: 3000), () {
      canShowProceedButton.value = true;
    });
  }

  void selectLanguageOption(int index) {
    if (index < 0 || index >= groups.length) return;
    final group = groups[index];
    if (group.isDropdown) {
      onSelectVariant(group.variants.first);
    } else {
      onSelectSingleGroup(group);
    }
  }

  void onSelectItem(int index) => selectLanguageOption(index);

  void restoreSavedLanguage() {
    final String currentSaved = AppUtil().getUserChoosedLanguage();
    final String savedVariant = AppUtil().getUserChoosedLanguageVariant();

    final int foundIndex =
        groups.indexWhere((g) => g.languageCode == currentSaved);
    final int targetIndex = foundIndex >= 0
        ? foundIndex
        : groups.indexWhere((g) => g.languageCode == 'en');
    final int safeIndex = targetIndex >= 0 ? targetIndex : 0;

    final LanguageGroupModel group = groups[safeIndex];
    selectedLangPosition.value = safeIndex;
    selectedLanguageCode.value = group.languageCode;

    if (group.isDropdown) {
      final bool hasMatchingVariant = savedVariant.isNotEmpty &&
          group.variants.any((v) => v.variantId == savedVariant);
      selectedVariantId.value = hasMatchingVariant
          ? savedVariant
          : group.variants.first.variantId;
    } else {
      selectedVariantId.value = group.groupId;
    }

    canShowProceedButton.value = true;
  }

  void getPreviousSelectedLanguage() => restoreSavedLanguage();

  void navigateBack() {
    Get.back();
  }

  void onSelectBack() => navigateBack();

  Future<void> applyLanguageAndContinue() async {
    final String chosenCode = selectedLanguageCode.value ??
        (selectedLangPosition.value >= 0 &&
                selectedLangPosition.value < availableLanguages.length
            ? availableLanguages[selectedLangPosition.value].languageCode
            : 'en');
    final String? chosenVariant = selectedVariantId.value;

    AppUtil().saveUserChoosedLanguage(chosenCode);
    if (chosenVariant != null && chosenVariant.isNotEmpty) {
      AppUtil().saveUserChoosedLanguageVariant(chosenVariant);
    }

    final Locale targetLocale = Locale(chosenCode);
    initializeDateFormatting(chosenCode);
    AppSetting.selectedLanguageCode = chosenCode;
    Get.updateLocale(targetLocale);

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchCategories();
    }

    if (Get.isRegistered<ChatsController>()) {
      Get.find<ChatsController>().updateSessionLocalizations();
    }

    if (Get.isRegistered<ChatDetailController>()) {
      Get.find<ChatDetailController>().refreshLocalizedInfo();
    }

    if (!isFirstLaunchFlow.value) {
      Get.back();
      if (Get.isRegistered<SettingController>()) {
        Get.back();
      }
    } else {
      await Get.offAllWithController(
        controllerBuilder: () => OnboardController(),
        page: () => const OnboardPage(),
      );
    }
  }

  Future<void> onClickNext() => applyLanguageAndContinue();

  @override
  void onClose() {
    _nextDelayTimer?.cancel();
    _loadingTimer?.cancel();
    super.onClose();
  }
}
