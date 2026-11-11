import 'dart:math' as math;
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/values/app_colors.dart';
import '../../models/language_model.dart';
import '../../utils/app_setting.dart';
import 'language_controller.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _dropdownGroupKeys = {};
  String? _autoRevealGroupId;

  LanguageController get controller => Get.isRegistered<LanguageController>()
      ? Get.find<LanguageController>()
      : Get.put(LanguageController());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildLanguageTopBar(),
                    Flexible(
                      flex: 1,
                      child: _buildLanguageOptionList(context),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Obx(() {
                  if (AppSetting.isPremiumUser.value ||
                      AppSetting.isRemoveAds.value ||
                      !controller.isFirstLaunchFlow.value) {
                    return const SizedBox();
                  }

                  final bool showInitial = controller.isPrimaryLangAdEnabled;
                  final bool showAlt = controller.isSecondaryLangAdEnabled;

                  if (!showInitial && !showAlt) {
                    return const SizedBox();
                  }

                  if (controller.isSecondaryAdActive.value && showAlt) {
                    return EasyNativeAdSequential(
                      key: const ValueKey('nativeLanguageClick'),
                      factoryId: 'nativeMedia2',
                      adId: MyAdIdName.nativeLanguageClick.getId,
                      cacheKey: MyAdIdName.nativeLanguageClick,
                      adIdHigh: MyAdIdName.nativeLanguageClickHigh.getId,
                      cacheKeyHigh: MyAdIdName.nativeLanguageClickHigh,
                      height: AdDimen.mediumNativeHeight,
                    );
                  }

                  if (showInitial) {
                    return EasyNativeAdSequential(
                      key: const ValueKey('nativeLanguage'),
                      factoryId: 'nativeMedia',
                      adId: MyAdIdName.nativeLanguage.getId,
                      cacheKey: MyAdIdName.nativeLanguage,
                      adIdHigh: MyAdIdName.nativeLanguageHigh.getId,
                      cacheKeyHigh: MyAdIdName.nativeLanguageHigh,
                      height: AdDimen.mediumNativeHeight,
                    );
                  }

                  return const SizedBox();
                }),
              ),
            ),
            Obx(() {
              if (!controller.isLanguageLoading.value) return const SizedBox();
              return Positioned.fill(
                child: Container(
                  color: AppColors.bgPrimary.withValues(alpha: 0.8),
                  child: Center(
                    child: Lottie.asset(
                      'assets/json/loading.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOptionList(BuildContext context) {
    return Obx(() {
      final bool hasAd = controller.isFirstLaunchFlow.value &&
          !AppSetting.isPremiumUser.value &&
          !AppSetting.isRemoveAds.value &&
          (controller.isPrimaryLangAdEnabled ||
              controller.isSecondaryLangAdEnabled);

      final groups = controller.groups;
      // Subscribe to reactive selection/expansion states inside Obx
      controller.expandedGroupId.value;
      controller.selectedVariantId.value;
      controller.showEnglishHandHint.value;

      return ListView.builder(
        controller: _scrollController,
        itemCount: groups.length,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: hasAd
              ? (AdDimen.mediumNativeHeight +
                  MediaQuery.of(context).padding.bottom +
                  16)
              : 24,
          top: 12,
        ),
        itemBuilder: (context, index) {
          final group = groups[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: group.isDropdown
                ? _buildDropdownGroup(group)
                : _buildSingleLanguageCard(group),
          );
        },
      );
    });
  }

  BoxDecoration _languageCardDecoration({required bool isSelected}) {
    final radius = BorderRadius.circular(22);
    if (isSelected) {
      return BoxDecoration(
        borderRadius: radius,
        gradient: AppColors.primaryGradient,
      );
    }
    return BoxDecoration(
      borderRadius: radius,
      color: AppColors.backgroundItemColor,
      border: Border.all(
        color: AppColors.borderDefault,
        width: 1.0,
      ),
    );
  }

  Widget _buildSingleLanguageCard(LanguageGroupModel group) {
    final bool isSelected = controller.selectedVariantId.value == group.groupId;

    return GestureDetector(
      key: ValueKey('lang_single_${group.groupId}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.onSelectSingleGroup(group),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 62,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: _languageCardDecoration(isSelected: isSelected),
        child: Row(
          children: [
            _CircularCountryFlag(
              countryCode: group.singleCountryCode ?? 'us',
              pngAsset: group.pngAsset,
              size: 36,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _TwoLineLanguageLabel(
                title: group.title,
                nativeSubtitle: group.nativeName,
                isSelected: isSelected,
              ),
            ),
            const SizedBox(width: 10),
            _LanguageRadioDot(isSelected: isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownGroup(LanguageGroupModel group) {
    final groupBoxKey =
        _dropdownGroupKeys.putIfAbsent(group.groupId, () => GlobalKey());
    final bool isExpanded = controller.expandedGroupId.value == group.groupId;
    final bool hasSelectedChild = group.variants.any(
      (v) => v.variantId == controller.selectedVariantId.value,
    );
    final bool highlightParentAsSelected = hasSelectedChild && !isExpanded;
    final bool showHandOnEnglish =
        group.groupId == 'en' && controller.showEnglishHandHint.value;

    return Column(
      key: groupBoxKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              key: ValueKey('lang_group_${group.groupId}'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final bool willExpand =
                    controller.expandedGroupId.value != group.groupId;
                _autoRevealGroupId = willExpand ? group.groupId : null;
                controller.onToggleDropdownGroup(group);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 62,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: _languageCardDecoration(
                  isSelected: highlightParentAsSelected,
                ),
                child: Row(
                  children: [
                    _TranslateGroupBadge(groupId: group.groupId),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _TwoLineLanguageLabel(
                        title: group.title,
                        nativeSubtitle: group.nativeName,
                        isSelected: highlightParentAsSelected,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: highlightParentAsSelected
                            ? AppColors.whiteText
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showHandOnEnglish)
              const Positioned(
                right: 6,
                bottom: -8,
                child: IgnorePointer(
                  child: _AnimatedEnglishTapHand(
                    key: ValueKey('english_tap_hand_hint'),
                  ),
                ),
              ),
          ],
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: isExpanded ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeOutCubic,
          builder: (context, factor, child) {
            if (_autoRevealGroupId == group.groupId && factor > 0.0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || !_scrollController.hasClients) return;
                if (_autoRevealGroupId != group.groupId) return;
                final ctx = groupBoxKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(
                    ctx,
                    alignmentPolicy:
                        ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                  );
                }
                if (factor >= 1.0) {
                  _autoRevealGroupId = null;
                }
              });
            }
            if (factor <= 0.0) {
              return const SizedBox.shrink();
            }
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: factor,
                child: child,
              ),
            );
          },
          child: isExpanded
              ? _buildExpandedVariantsTree(group)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildExpandedVariantsTree(LanguageGroupModel group) {
    const double childHeight = 58.0;
    const double childGap = 10.0;
    const double topGap = 10.0;
    const double childIndent = 38.0;
    const double trunkX = 22.0;

    return CustomPaint(
      painter: _DropdownTreeConnectorPainter(
        itemCount: group.variants.length,
        topGap: topGap,
        itemHeight: childHeight,
        itemGap: childGap,
        trunkX: trunkX,
        childLeftX: childIndent,
        cornerRadius: 12.0,
        lineColor: const Color(0xFFD0D4DC),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: childIndent, top: topGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(group.variants.length, (idx) {
            final variant = group.variants[idx];
            final bool isLast = idx == group.variants.length - 1;
            final bool isSelected =
                controller.selectedVariantId.value == variant.variantId;

            return GestureDetector(
              key: ValueKey('lang_variant_${variant.variantId}'),
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.onSelectVariant(variant),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: childHeight,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: isLast ? 0 : childGap),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: _languageCardDecoration(isSelected: isSelected),
                child: Row(
                  children: [
                    Expanded(
                      child: _TwoLineLanguageLabel(
                        title: variant.title,
                        nativeSubtitle: variant.nativeName,
                        isSelected: isSelected,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CircularCountryFlag(
                      countryCode: variant.countryCode,
                      pngAsset: variant.pngAsset,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    _LanguageRadioDot(isSelected: isSelected),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLanguageTopBar() {
    return SizedBox(
      height: 72,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Language".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Please select a language to continue.".tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteText.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isFirstLaunchFlow.value) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: 0,
              bottom: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  controller.navigateBack();
                },
                child: const AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.whiteText,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Obx(() => (controller.hasSelection ||
                      controller.selectedLangPosition.value != 100) &&
                  controller.canShowProceedButton.value
              ? Positioned(
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: GestureDetector(
                    key: const ValueKey('language_done_button'),
                    onTap: () {
                      controller.applyLanguageAndContinue();
                    },
                    child: const SizedBox(
                      width: 80,
                      height: 36,
                      child: Center(
                        child: Icon(
                          Icons.done_all,
                          color: AppColors.main,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Obx(() => (controller.hasSelection ||
                      controller.selectedLangPosition.value != 100) &&
                  !controller.canShowProceedButton.value
              ? const Positioned(
                  right: 20,
                  bottom: 0,
                  top: 0,
                  child: Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.main,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _TwoLineLanguageLabel extends StatelessWidget {
  final String title;
  final String nativeSubtitle;
  final bool isSelected;

  const _TwoLineLanguageLabel({
    required this.title,
    required this.nativeSubtitle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.whiteText,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                nativeSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.whiteText.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRadioDot extends StatelessWidget {
  final bool isSelected;

  const _LanguageRadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: isSelected ? 2.0 : 1.5,
          color: isSelected ? AppColors.white : AppColors.textHint,
        ),
      ),
      child: isSelected
          ? Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
            )
          : null,
    );
  }
}

class _CircularCountryFlag extends StatelessWidget {
  final String countryCode;
  final String? pngAsset;
  final double size;

  const _CircularCountryFlag({
    required this.countryCode,
    this.pngAsset,
    required this.size,
  });

  static const Set<String> _customPaintedCodes = {
    'gb',
    'eg',
    'ae',
    'mx',
    'ar',
    'br',
  };

  @override
  Widget build(BuildContext context) {
    final code = countryCode.toLowerCase();
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: _customPaintedCodes.contains(code) ||
                pngAsset == null ||
                pngAsset!.isEmpty
            ? CustomPaint(
                size: Size(size, size),
                painter: _RegionalFlagPainter(countryCode: code),
              )
            : Image.asset(
                pngAsset!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class _RegionalFlagPainter extends CustomPainter {
  final String countryCode;

  const _RegionalFlagPainter({required this.countryCode});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    switch (countryCode) {
      case 'gb':
        // Union Jack (UK)
        canvas.drawRect(rect, Paint()..color = const Color(0xFF012169));
        final whiteDiag = Paint()
          ..color = Colors.white
          ..strokeWidth = w * 0.20
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(0, 0), Offset(w, h), whiteDiag);
        canvas.drawLine(Offset(w, 0), Offset(0, h), whiteDiag);

        final redDiag = Paint()
          ..color = const Color(0xFFC8102E)
          ..strokeWidth = w * 0.08
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(0, 0), Offset(w, h), redDiag);
        canvas.drawLine(Offset(w, 0), Offset(0, h), redDiag);

        final whiteCross = Paint()..color = Colors.white;
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(w / 2, h / 2), width: w * 0.30, height: h),
            whiteCross);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(w / 2, h / 2), width: w, height: h * 0.30),
            whiteCross);

        final redCross = Paint()..color = const Color(0xFFC8102E);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(w / 2, h / 2), width: w * 0.18, height: h),
            redCross);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(w / 2, h / 2), width: w, height: h * 0.18),
            redCross);
        break;

      case 'eg':
        // Egypt: Red, White, Black horizontal stripes + gold emblem
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h / 3),
            Paint()..color = const Color(0xFFCE1126));
        canvas.drawRect(
            Rect.fromLTWH(0, h / 3, w, h / 3), Paint()..color = Colors.white);
        canvas.drawRect(Rect.fromLTWH(0, 2 * h / 3, w, h / 3),
            Paint()..color = const Color(0xFF000000));
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.09,
            Paint()..color = const Color(0xFFC09300));
        break;

      case 'ae':
        // UAE: Green, White, Black horizontal stripes + vertical Red bar on left
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h / 3),
            Paint()..color = const Color(0xFF00732F));
        canvas.drawRect(
            Rect.fromLTWH(0, h / 3, w, h / 3), Paint()..color = Colors.white);
        canvas.drawRect(Rect.fromLTWH(0, 2 * h / 3, w, h / 3),
            Paint()..color = const Color(0xFF000000));
        canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.28, h),
            Paint()..color = const Color(0xFFFF0000));
        break;

      case 'mx':
        // Mexico: Green, White, Red vertical stripes + emblem
        canvas.drawRect(Rect.fromLTWH(0, 0, w / 3, h),
            Paint()..color = const Color(0xFF006847));
        canvas.drawRect(
            Rect.fromLTWH(w / 3, 0, w / 3, h), Paint()..color = Colors.white);
        canvas.drawRect(Rect.fromLTWH(2 * w / 3, 0, w / 3, h),
            Paint()..color = const Color(0xFFCE1126));
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.09,
            Paint()..color = const Color(0xFF6B4E23));
        break;

      case 'ar':
        // Argentina: Light blue, White, Light blue horizontal + sun
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h / 3),
            Paint()..color = const Color(0xFF74ACDF));
        canvas.drawRect(
            Rect.fromLTWH(0, h / 3, w, h / 3), Paint()..color = Colors.white);
        canvas.drawRect(Rect.fromLTWH(0, 2 * h / 3, w, h / 3),
            Paint()..color = const Color(0xFF74ACDF));
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.10,
            Paint()..color = const Color(0xFFF6B40E));
        break;

      case 'br':
        // Brazil: Green background, yellow diamond, blue circle
        canvas.drawRect(rect, Paint()..color = const Color(0xFF009B3A));
        final diamond = Path()
          ..moveTo(w / 2, h * 0.14)
          ..lineTo(w * 0.88, h / 2)
          ..lineTo(w / 2, h * 0.86)
          ..lineTo(w * 0.12, h / 2)
          ..close();
        canvas.drawPath(diamond, Paint()..color = const Color(0xFFFEDF00));
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.20,
            Paint()..color = const Color(0xFF002776));
        break;

      default:
        canvas.drawRect(rect, Paint()..color = const Color(0xFF2878FF));
        const angleStep = 2 * math.pi / 5;
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.25 + angleStep * 0,
            Paint()..color = Colors.white);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _RegionalFlagPainter oldDelegate) =>
      oldDelegate.countryCode != countryCode;
}

/// Circular globe badge with distinct gradient theme and centered language code (`EN`, `ES`, `PT`, `AR`).
class _TranslateGroupBadge extends StatelessWidget {
  final String groupId;

  const _TranslateGroupBadge({required this.groupId});

  ({
    List<Color> gradientColors,
    Color gridColor,
    Color pillFill,
    Color pillBorder,
    Color textColor,
  }) _themeForCode(String code) {
    switch (code) {
      case 'en':
        return (
          gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF0F172A)],
          gridColor: const Color(0x8893C5FD),
          pillFill: const Color(0xE60F172A),
          pillBorder: const Color(0xFF60A5FA),
          textColor: const Color(0xFFFFFFFF),
        );
      case 'es':
        return (
          gradientColors: const [Color(0xFFF59E0B), Color(0xFFE11D48), Color(0xFF4C0519)],
          gridColor: const Color(0x99FDE68A),
          pillFill: const Color(0xE63B0714),
          pillBorder: const Color(0xFFFBBF24),
          textColor: const Color(0xFFFFFBEB),
        );
      case 'pt':
        return (
          gradientColors: const [Color(0xFF10B981), Color(0xFF047857), Color(0xFF064E3B)],
          gridColor: const Color(0x99A7F3D0),
          pillFill: const Color(0xE6042F2E),
          pillBorder: const Color(0xFFFACC15),
          textColor: const Color(0xFFFEF08A),
        );
      case 'ar':
        return (
          gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9), Color(0xFF2E1065)],
          gridColor: const Color(0x99DDD6FE),
          pillFill: const Color(0xE61E1B4B),
          pillBorder: const Color(0xFFC4B5FD),
          textColor: const Color(0xFFFFFFFF),
        );
      default:
        return (
          gradientColors: const [Color(0xFF6366F1), Color(0xFF3730A3)],
          gridColor: const Color(0x88C7D2FE),
          pillFill: const Color(0xE61E1B4B),
          pillBorder: const Color(0xFF818CF8),
          textColor: const Color(0xFFFFFFFF),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double circleSize = 36;
    final code = groupId.toLowerCase();
    final label = code.toUpperCase();
    final theme = _themeForCode(code);

    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradientColors,
        ),
        border: Border.all(
          color: theme.pillBorder.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.gradientColors.first.withValues(alpha: 0.28),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(circleSize, circleSize),
              painter: _GlobeGridPainter(lineColor: theme.gridColor),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2.2),
              decoration: BoxDecoration(
                color: theme.pillFill,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.pillBorder,
                  width: 1.0,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobeGridPainter extends CustomPainter {
  final Color lineColor;

  const _GlobeGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = (w / 2) - 2.0;

    final gridPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..isAntiAlias = true;

    // Outer globe ring
    canvas.drawCircle(center, r, gridPaint);

    // Vertical meridian + curved longitude ellipses
    canvas.drawLine(Offset(center.dx, center.dy - r),
        Offset(center.dx, center.dy + r), gridPaint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: r * 1.12, height: r * 2),
      gridPaint,
    );

    // Equator + upper & lower latitude parallels
    canvas.drawLine(Offset(center.dx - r, center.dy),
        Offset(center.dx + r, center.dy), gridPaint);

    final latOffset = r * 0.52;
    final latHalfWidth = math.sqrt(r * r - latOffset * latOffset);
    canvas.drawLine(
      Offset(center.dx - latHalfWidth, center.dy - latOffset),
      Offset(center.dx + latHalfWidth, center.dy - latOffset),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx - latHalfWidth, center.dy + latOffset),
      Offset(center.dx + latHalfWidth, center.dy + latOffset),
      gridPaint,
    );

    // Top-left specular highlight
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.34, h * 0.26),
        width: w * 0.36,
        height: h * 0.18,
      ),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlobeGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

/// Paints the vertical trunk line + rounded L-shaped branches connecting the
/// expanded parent language card to each indented regional child card.
class _DropdownTreeConnectorPainter extends CustomPainter {
  final int itemCount;
  final double topGap;
  final double itemHeight;
  final double itemGap;
  final double trunkX;
  final double childLeftX;
  final double cornerRadius;
  final Color lineColor;

  const _DropdownTreeConnectorPainter({
    required this.itemCount,
    required this.topGap,
    required this.itemHeight,
    required this.itemGap,
    required this.trunkX,
    required this.childLeftX,
    required this.cornerRadius,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount <= 0) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final maxR = (childLeftX - trunkX).clamp(2.0, cornerRadius);
    final lastCenterY =
        topGap + (itemCount - 1) * (itemHeight + itemGap) + itemHeight / 2;

    final spineEndY = (lastCenterY - maxR).clamp(0.0, size.height);
    canvas.drawLine(Offset(trunkX, 0), Offset(trunkX, spineEndY), paint);

    for (int i = 0; i < itemCount; i++) {
      final centerY = topGap + i * (itemHeight + itemGap) + itemHeight / 2;
      final startY = (centerY - maxR).clamp(0.0, centerY);
      final r = (centerY - startY).clamp(1.0, maxR);

      final branchPath = Path()
        ..moveTo(trunkX, startY)
        ..arcToPoint(
          Offset(trunkX + r, centerY),
          radius: Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(childLeftX, centerY);

      canvas.drawPath(branchPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DropdownTreeConnectorPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.itemHeight != itemHeight ||
        oldDelegate.lineColor != lineColor;
  }
}

/// Animated cartoon tapping hand + ripple hint guiding users to tap `English`.
class _AnimatedEnglishTapHand extends StatefulWidget {
  const _AnimatedEnglishTapHand({super.key});

  @override
  State<_AnimatedEnglishTapHand> createState() =>
      _AnimatedEnglishTapHandState();
}

class _AnimatedEnglishTapHandState extends State<_AnimatedEnglishTapHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double boxSize = 46;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        double press;
        if (t < 0.44) {
          press = Curves.easeOutCubic.transform(t / 0.44);
        } else if (t < 0.86) {
          press = 1.0 - Curves.easeInOut.transform((t - 0.44) / 0.42);
        } else {
          press = 0.0;
        }

        final rippleT = ((t - 0.24) / 0.62).clamp(0.0, 1.0);
        final rippleScale = 0.45 + rippleT * 1.15;
        final rippleAlpha = (1.0 - rippleT) * 0.75;

        final dx = (1.0 - press) * 4.5;
        final dy = (1.0 - press) * 5.5;
        final handScale = 1.0 - press * 0.11;

        return SizedBox(
          width: boxSize,
          height: boxSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 5,
                top: 3,
                child: Opacity(
                  opacity: rippleAlpha.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: rippleScale,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0x52FFFFFF),
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 6 + dx,
                top: 6 + dy,
                child: Transform.scale(
                  scale: handScale,
                  alignment: Alignment.topLeft,
                  child: Transform.rotate(
                    angle: -0.46,
                    alignment: Alignment.topCenter,
                    child: const CustomPaint(
                      size: Size(32, 34),
                      painter: _CartoonPointingHandPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartoonPointingHandPainter extends CustomPainter {
  const _CartoonPointingHandPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 36.0;
    final sy = size.height / 38.0;

    Path buildHandPath() {
      final p = Path();
      p.moveTo(12.5 * sx, 19.5 * sy);
      p.lineTo(12.5 * sx, 5.2 * sy);
      p.arcToPoint(
        Offset(18.2 * sx, 5.2 * sy),
        radius: Radius.elliptical(2.85 * sx, 2.85 * sy),
        clockwise: true,
      );
      p.lineTo(18.2 * sx, 13.8 * sy);
      p.arcToPoint(
        Offset(23.4 * sx, 15.0 * sy),
        radius: Radius.elliptical(2.65 * sx, 2.65 * sy),
        clockwise: true,
      );
      p.lineTo(23.4 * sx, 16.0 * sy);
      p.arcToPoint(
        Offset(28.3 * sx, 17.4 * sy),
        radius: Radius.elliptical(2.55 * sx, 2.55 * sy),
        clockwise: true,
      );
      p.lineTo(28.3 * sx, 18.6 * sy);
      p.arcToPoint(
        Offset(32.6 * sx, 20.6 * sy),
        radius: Radius.elliptical(2.35 * sx, 2.35 * sy),
        clockwise: true,
      );
      p.lineTo(32.6 * sx, 25.0 * sy);
      p.cubicTo(
        32.6 * sx,
        31.2 * sy,
        28.8 * sx,
        35.0 * sy,
        22.5 * sx,
        35.0 * sy,
      );
      p.lineTo(16.0 * sx, 35.0 * sy);
      p.cubicTo(
        12.4 * sx,
        35.0 * sy,
        9.8 * sx,
        31.5 * sy,
        5.2 * sx,
        24.6 * sy,
      );
      p.arcToPoint(
        Offset(9.6 * sx, 21.0 * sy),
        radius: Radius.elliptical(2.7 * sx, 2.7 * sy),
        clockwise: true,
      );
      p.lineTo(12.5 * sx, 23.6 * sy);
      p.close();
      return p;
    }

    final handPath = buildHandPath();

    canvas.drawShadow(handPath, const Color(0xA6000000), 3.5, true);

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF15161A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(handPath, fillPaint);
    canvas.drawPath(handPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CartoonPointingHandPainter oldDelegate) =>
      false;
}
