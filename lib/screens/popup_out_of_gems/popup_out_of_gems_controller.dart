import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../helper/firebase_helper.dart';
import '../../utils/app_setting.dart';
import '../profile/profile_controller.dart';

class PopupOutOfGemsController extends BaseController {
  final VoidCallback? onWatchAdSuccess;
  final VoidCallback? onGoPremium;

  PopupOutOfGemsController({this.onWatchAdSuccess, this.onGoPremium});

  ProfileController get profileController =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  @override
  void onInit() {
    super.onInit();
    FirebaseHelper.setTrackingScreenName("PopupOutOfGems");
  }

  void onCloseButton() {
    Get.back();
  }

  void onWatchAd() {
    Get.back();
    final ctx = Get.context;
    if (ctx == null) return;
    AppSetting.showRewardToUnlock(
      ctx,
      onUnlocked: () {
        if (onWatchAdSuccess != null) {
          onWatchAdSuccess!();
        }
      },
    );
  }

  void onGoToShop() {
    Get.back();
  }
}
