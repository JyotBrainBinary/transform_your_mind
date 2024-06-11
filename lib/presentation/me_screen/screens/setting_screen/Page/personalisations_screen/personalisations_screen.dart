import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transform_your_mind/core/app_export.dart';
import 'package:transform_your_mind/core/service/pref_service.dart';
import 'package:transform_your_mind/core/utils/color_constant.dart';
import 'package:transform_your_mind/core/utils/dimensions.dart';
import 'package:transform_your_mind/core/utils/extension_utils.dart';
import 'package:transform_your_mind/core/utils/image_constant.dart';
import 'package:transform_your_mind/core/utils/prefKeys.dart';
import 'package:transform_your_mind/core/utils/style.dart';
import 'package:transform_your_mind/presentation/me_screen/screens/setting_screen/Page/personalisations_screen/personalisations_controller.dart';
import 'package:transform_your_mind/theme/theme_controller.dart';
import 'package:transform_your_mind/widgets/custom_appbar.dart';

class PersonalizationScreenScreen extends StatefulWidget {
  PersonalizationScreenScreen({super.key});

  @override
  State<PersonalizationScreenScreen> createState() =>
      _PersonalizationScreenScreenState();
}

class _PersonalizationScreenScreenState
    extends State<PersonalizationScreenScreen> {
  PersonalizationController personalizationController =
      Get.put(PersonalizationController());

  ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: ColorConstant.backGround, // Status bar background color
      statusBarIconBrightness: Brightness.dark, // Status bar icon/text color
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: themeController.isDarkMode.value
            ? ColorConstant.black
            : ColorConstant.backGround,
        appBar: CustomAppBar(title: "chooseLanguage".tr),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Dimens.d101.spaceHeight,
              Container(
                width: Get.width,
                decoration: BoxDecoration(
                    color: themeController.isDarkMode.value
                        ? ColorConstant.textfieldFillColor
                        : ColorConstant.white,
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Dimens.d10.spaceHeight,
                    Text(
                      "chooseYourLanguage".tr,
                      style: Style.montserratRegular(
                          fontSize: Dimens.d20, fontWeight: FontWeight.w500),
                    ),
                    Dimens.d14.spaceHeight,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 47),
                      child: Text(
                        "selectYourPreferred".tr,
                        textAlign: TextAlign.center,
                        style: Style.montserratRegular(fontSize: Dimens.d13),
                      ),
                    ),
                    Dimens.d40.spaceHeight,
                    Obx(
                      () => GestureDetector(
                        onTap: () async {
                          personalizationController.english.value = true;
                          personalizationController.german.value = false;

                          Locale newLocale;

                          newLocale = const Locale('en', 'US');
                          Get.updateLocale(newLocale);

                          await PrefService.setValue(
                                  PrefKey.language, newLocale.toLanguageTag());
                            },
                            child: Container(
                              height: 46,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 17),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80),
                                  color: ColorConstant.black.withOpacity(0.1)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    "English",
                                    style: Style.montserratRegular(
                                        fontSize: Dimens.d14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SvgPicture.asset(
                                    personalizationController.english.isTrue
                                        ? ImageConstant.select
                                        : ImageConstant.unSelect,
                                    height: 16,
                                    width: 16,
                                  )
                                ],
                              ),
                            ),
                          ),
                    ),
                    Dimens.d14.spaceHeight,
                    Obx(
                          () =>
                          GestureDetector(
                            onTap: () async {
                              personalizationController.german.value = true;
                              personalizationController.english.value = false;

                          Locale newLocale;

                          newLocale = const Locale('de', 'DE');
                              Get.updateLocale(newLocale);

                          await PrefService.setValue(
                              PrefKey.language, newLocale.toLanguageTag());
                        },
                        child: Container(
                          height: 46,
                          margin: const EdgeInsets.symmetric(horizontal: 17),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80),
                              color: ColorConstant.black.withOpacity(0.1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "German",
                                style: Style.montserratRegular(
                                    fontSize: Dimens.d14,
                                    fontWeight: FontWeight.w500),
                              ),
                              SvgPicture.asset(
                                personalizationController.german.isTrue
                                    ? ImageConstant.select
                                    : ImageConstant.unSelect,
                                height: 16,
                                width: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Dimens.d20.spaceHeight,
                  ],
                ),
              )
              /*    Text("Theme Change",
                  style: Style.cormorantGaramondBold(fontSize: 22)),
              Dimens.d15.spaceHeight,
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      themeController.switchTheme();
                      Get.forceAppUpdate();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: ColorConstant.themeColor),
                      child: Center(
                        child: Text(
                          "Dark",
                          style: Style.montserratRegular(
                              fontSize: 18, color: ColorConstant.white),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      themeController.switchTheme();
                      Get.forceAppUpdate();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: ColorConstant.themeColor),
                      child: Center(
                        child: Text(
                          "Light",
                          style: Style.montserratRegular(
                              fontSize: 18, color: ColorConstant.white),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              Dimens.d15.spaceHeight,
              Text("Language Change",
                  style: Style.cormorantGaramondBold(fontSize: 22)),
              Dimens.d15.spaceHeight,
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      Locale newLocale;

                      newLocale = const Locale('en', 'US');
                      Get.updateLocale(newLocale);

                      await PrefService.setValue(
                          PrefKey.language, newLocale.toLanguageTag());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: ColorConstant.themeColor),
                      child: Center(
                        child: Text(
                          "English",
                          style: Style.montserratRegular(
                              fontSize: 18, color: ColorConstant.white),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      Locale newLocale;

                      newLocale = const Locale('de', 'DE');
                      Get.updateLocale(newLocale);

                      await PrefService.setValue(
                          PrefKey.language, newLocale.toLanguageTag());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: ColorConstant.themeColor),
                      child: Center(
                        child: Text(
                          "French",
                          style: Style.montserratRegular(
                              fontSize: 18, color: ColorConstant.white),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

class AccountListItem extends StatelessWidget {
  AccountListItem({
    Key? key,
    required this.index,
    required this.title,
    //required this.suffixIcon,
    required this.isSettings,
    this.onTap,
  }) : super(key: key);

  final int index;
  final String title;

  //final String suffixIcon;
  final bool isSettings;
  final VoidCallback? onTap;

  ThemeController themeController = Get.find<ThemeController>();
  PersonalizationController pController = Get.put(PersonalizationController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1.2),
        decoration: BoxDecoration(
          color: themeController.isDarkMode.value
              ? ColorConstant.textfieldFillColor
              : ColorConstant.white,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.d10,
          vertical: Dimens.d10,
        ),
        child: Row(
          //mainAxisSize: MainAxisSize.min,
          children: [
            Dimens.d12.spaceWidth,
            Text(
              title,
              style: Style.montserratMedium(fontSize: 14).copyWith(
                letterSpacing: Dimens.d0_16,
              ),
            ),
            const Spacer(),
            /*   index == 0
                ? CustomSwitch(
                    value: themeController.isDarkMode.value,
                    onChanged: (value) async {
                      themeController.switchTheme();
                      Get.forceAppUpdate();
                    },
                    width: 50.0,
                    height: 25.0,
                    activeColor: ColorConstant.themeColor,
                    inactiveColor: ColorConstant.backGround,
                  )
                : CustomSwitch(
                    value: pController.language.value,
                    onChanged: (value) async {

                      pController.language.value = value;
                      pController.onTapChangeLan();
                    },
                    width: 50.0,
                    height: 25.0,
                    activeColor: ColorConstant.themeColor,
                    inactiveColor: ColorConstant.backGround,
                  ),*/
            Dimens.d6.spaceWidth,
          ],
        ),
      ),
    );
  }
}
