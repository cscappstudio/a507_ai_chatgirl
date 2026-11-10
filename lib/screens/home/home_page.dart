import 'package:cscmobi_app/ads/dimens/ad_dimen.dart';
import 'package:cscmobi_app/utils/app_setting.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/values/app_colors.dart';
import 'home_controller.dart';
import 'home_inline_ad_models.dart';
import '../../models/character_model.dart';
import '../../models/category_model.dart';
import 'widgets/inline_ad_slot_widget.dart';
import '../../helper/firebase_remote_config_service.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static const Color _inlineCardBottomColor = AppColors.bgSecondary;

  @override
  HomeController get controller => Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final floatingFabOffset = 20.0 + bottomInset;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(),
                  Obx(() {
                    final bool showNativeHome = FirebaseRemoteConfigService.getBoolConfigByKey(
                        FirebaseRemoteConfigService.native_home);
                    if (AppSetting.isPremiumUser.value ||
                        AppSetting.isRemoveAds.value ||
                        !showNativeHome) {
                      return const SizedBox();
                    }
                    return Container(
                      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                      child: EasyNativeAd(
                        key: const ValueKey('nativeHomeBanner'),
                        factoryId: 'nativeMediaSmall',
                        adId: MyAdIdName.nativeHome.getId,
                        height: AdDimen.smallNativeAdHeight,
                      ),
                    );
                  }),
                  _buildCategoryTabs(),
                  Expanded(
                    child: Obx(() {
                      final chars = List<CharacterModel>.unmodifiable(
                        controller.filteredCharacters,
                      );

                      if (chars.isEmpty) {
                        return _buildEmptyState('No characters found'.tr);
                      }
                      final placements = List<HomeGridPlacement>.unmodifiable(
                        controller.canLoadInlineAds
                            ? controller.inlinePlacements
                            : controller.buildContentOnlyPlacements(chars.length),
                      );

                      return GridView.builder(
                        controller: controller.inlineGridScrollController,
                        cacheExtent: 350,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 16.0, bottom: 170.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.58,
                        ),
                        itemCount: placements.length,
                        itemBuilder: (context, index) {
                          final placement = placements[index];
                          if (placement.isInlineAd) {
                            final slotIndex = placement.slotIndex;
                            return _buildInlineNativeAdCard(
                              slotIndex: slotIndex,
                              adConfig: controller.getInlineAdConfig(slotIndex),
                            );
                          }

                          final charIndex = placement.characterIndex;
                          if (charIndex < 0 || charIndex >= chars.length) {
                            return const SizedBox.shrink();
                          }

                          return _buildCharacterCard(chars[charIndex]);
                        },
                      );
                    }),
                  ),
                ],
              ),
              Obx(() {
                if (controller.isLoadingCategories.value ||
                    controller.isLoadingCharacters.value) {
                  return Container(
                    color: AppColors.backgroundColor.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/png/empty.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSubColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidNetworkUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
    return uri.host.isNotEmpty;
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: controller.onSelectBonusGem,
      child: Image.asset(
        'assets/png/bonus_gem.png',
        width: 84,
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 4.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 10.0, bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonShadow.withValues(alpha: 0.22),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/png/ic_waifu.png',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF23193A), Color(0xFF1A142C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: AppColors.borderActive.withValues(alpha: 0.42),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonShadow.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonLavender.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Image.asset(
                      'assets/png/ic_search.png',
                      width: 17,
                      height: 17,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.searchEditController,
                      onChanged: controller.updateSearchText,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: AppColors.primaryPurple,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        hintText: 'Search your waifu...'.tr,
                        hintStyle: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Obx(() => controller.searchText.value.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.searchEditController.clear();
                            controller.updateSearchText('');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.close,
                                color: AppColors.textSubColor, size: 18),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const SizedBox(height: 48);
      }
      return Container(
        height: 38,
        margin: const EdgeInsets.only(top: 14.0, bottom: 6.0),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            ...controller.categories.map((cat) => _buildTabItem(
                  title: cat.name ?? '',
                  category: cat,
                  isSelected: controller.selectedCategory.value?.id == cat.id,
                )),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem(
      {required String title,
      CategoryModel? category,
      required bool isSelected}) {
    return GestureDetector(
      onTap: () => controller.selectCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.only(right: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: isSelected ? AppColors.primaryButtonGradient : null,
          color: isSelected ? null : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.borderActive : AppColors.borderDefault,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonShadow.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard(CharacterModel char) {
    return _CharacterCardItem(
      key: ValueKey('home-char-${char.id ?? char.avatarUrl ?? char.name}'),
      controller: controller,
      char: char,
      isValidNetworkUrl: _isValidNetworkUrl,
    );
  }

  Widget _buildInlineNativeAdCard({
    required int slotIndex,
    required HomeInlineAdConfig adConfig,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: _inlineCardBottomColor,
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonShadow.withValues(alpha: 0.15),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InlineAdSlotWidget(
        key: ValueKey('home-inline-ad-$slotIndex'),
        controller: controller,
        slotIndex: slotIndex,
        adConfig: adConfig,
      ),
    );
  }
}

class _CharacterCardItem extends StatelessWidget {
  const _CharacterCardItem({
    super.key,
    required this.controller,
    required this.char,
    required this.isValidNetworkUrl,
  });

  final HomeController controller;
  final CharacterModel char;
  final bool Function(String url) isValidNetworkUrl;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final int memCacheWidth = ((screenWidth / 2) * pixelRatio).round().clamp(200, 600);
    final int memCacheHeight = (memCacheWidth / 0.58).round();

    return GestureDetector(
      onTap: () => controller.goToCharacterDetail(char),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: AppColors.cardGradient,
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonShadow.withValues(alpha: 0.15),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Builder(builder: (context) {
                    final imgUrl = controller.getFormattedAvatar(char);
                    if (imgUrl.isEmpty || !isValidNetworkUrl(imgUrl)) {
                      return Container(
                        color: AppColors.secondColor,
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white24,
                            size: 40,
                          ),
                        ),
                      );
                    }
                    return CachedNetworkImage(
                      imageUrl: imgUrl,
                      memCacheWidth: memCacheWidth,
                      memCacheHeight: memCacheHeight,
                      fit: BoxFit.fill,
                      fadeInDuration: Duration.zero,
                      placeholderFadeInDuration: Duration.zero,
                      errorWidget: (context, url, error) =>
                          Container(color: AppColors.secondColor),
                    );
                  }),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: AppColors.lightPink,
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.formatLikes(char.likes ?? 0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    char.name ?? 'Unknown',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: (char.tags != null && char.tags!.isNotEmpty)
                        ? char.tags!
                            .take(2)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: AppColors.neonLavender,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList()
                        : [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Text(
                                'Mystery',
                                style: TextStyle(
                                  color: AppColors.neonLavender,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Created by '.tr,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          char.creatorUsername != null &&
                                  char.creatorUsername!.isNotEmpty
                              ? (char.creatorUsername!.startsWith('@')
                                  ? char.creatorUsername!
                                  : '@${char.creatorUsername}')
                              : '@unknown',
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
