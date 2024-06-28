import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:transform_your_mind/core/common_widget/custom_chip.dart';
import 'package:transform_your_mind/core/common_widget/custom_screen_loader.dart';
import 'package:transform_your_mind/core/common_widget/select_focus_button.dart';
import 'package:transform_your_mind/core/common_widget/snack_bar.dart';
import 'package:transform_your_mind/core/service/pref_service.dart';
import 'package:transform_your_mind/core/utils/color_constant.dart';
import 'package:transform_your_mind/core/utils/dimensions.dart';
import 'package:transform_your_mind/core/utils/end_points.dart';
import 'package:transform_your_mind/core/utils/extension_utils.dart';
import 'package:transform_your_mind/core/utils/image_constant.dart';
import 'package:transform_your_mind/core/utils/prefKeys.dart';
import 'package:transform_your_mind/core/utils/style.dart';
import 'package:transform_your_mind/model_class/focus_model.dart';
import 'package:transform_your_mind/presentation/intro_screen/select_your_affirmation_focus_page.dart';
import 'package:transform_your_mind/theme/theme_controller.dart';
import 'package:transform_your_mind/widgets/custom_appbar.dart';
class Tag {
  final String name;
  bool isSelected;

  Tag(this.name, this.isSelected);
}

class SelectYourFocusPage extends StatefulWidget {
  const SelectYourFocusPage({
    Key? key,
    required this.isFromMe,
  }) : super(key: key);
  static const selectFocus = '/selectFocus';

  final bool isFromMe;

  @override
  State<SelectYourFocusPage> createState() => _SelectYourFocusPageState();
}

class _SelectYourFocusPageState extends State<SelectYourFocusPage> {
  List<Tag> listOfTags = [];
  bool loader = false;

  List<String> selectedTagNames = [];

  ThemeController themeController = Get.find<ThemeController>();
  FocusesModel focusesModel = FocusesModel();

  getFocuses() async {
    var headers = {
      'Authorization': 'Bearer ${PrefService.getString(PrefKey.token)}'
    };
    var request = http.Request(
      'GET',
      Uri.parse(
          '${EndPoints.baseUrl}${EndPoints.getCategory}0'),
    );
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      focusesModel = focusesModelFromJson(responseBody);
      for (int i = 0; i < focusesModel.data!.length; i++) {
        listOfTags.add(Tag(focusesModel.data![i].name.toString(), false));
      }
      setState(() {});
    } else {
      debugPrint(response.reasonPhrase);
    }
  }

  setFocuses() async {
    setState(() {
      loader = true;
    });
    try {
      var headers = {
        'Authorization': 'Bearer ${PrefService.getString(PrefKey.token)}'
      };
      var request = http.MultipartRequest('POST', Uri.parse('${EndPoints.baseUrl}${EndPoints.updateUser}${PrefService.getString(PrefKey.userId)}'));
      request.fields.addAll({
        'focuses': jsonEncode(selectedTagNames)
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        await PrefService.setValue(PrefKey.focuses, true);
        setState(() {
          loader = false;
        });
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return const SelectYourAffirmationFocusPage(isFromMe: false);
          },
        ));
      } else {
        setState(() {
          loader = false;
        });
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      setState(() {
        loader = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {

    getFocuses();
    setState(() {});
    super.initState();
  }

  void _onTagTap(Tag tag) {
    setState(() {
      tag.isSelected = !tag.isSelected;
      if (tag.isSelected) {
        selectedTagNames.add(tag.name);
      } else {
        selectedTagNames.remove(tag.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    themeController.isDarkMode.isTrue
        ? SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: ColorConstant.darkBackground,
            // Status bar background color
            statusBarIconBrightness:
                Brightness.light, // Status bar icon/text color
          ))
        : SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: ColorConstant.white, // Status bar background color
            statusBarIconBrightness:
                Brightness.dark, // Status bar icon/text color
          ));
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: themeController.isDarkMode.isTrue
                ? ColorConstant.darkBackground
                : ColorConstant.white,
            appBar:  CustomAppBar(showBack: false,
              title: "selectYourFocus".tr,
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: Dimens.d100),
                      child: SvgPicture.asset(ImageConstant.profile1),
                    )),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Dimens.d120),
                      child: SvgPicture.asset(ImageConstant.profile2),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                  child: Column(
                    children: [
                      Dimens.d30.spaceHeight,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "chooseMinInterest".tr,textAlign: TextAlign.center,
                          style: Style.gothamLight(
                              color: themeController.isDarkMode.value
                                  ? ColorConstant.white
                                  : ColorConstant.black,
                              fontSize: Dimens.d15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Dimens.d18.spaceHeight,
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: listOfTags.map((tag) {
                                return GestureDetector(
                                  onTap: () => _onTagTap(tag),
                                  child: CustomChip(
                                    label: tag.name,
                                    isChipSelected: tag.isSelected,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      FocusSelectButton(
                        primaryBtnText: widget.isFromMe ? "Save" : "Next",
                        secondaryBtnText: widget.isFromMe ? '' : "Skip",
                        isLoading: false,
                        primaryBtnCallBack: () {
                         // getFocuses();
                          if (selectedTagNames.length >= 5) {
                            setFocuses();
                          } else {
                            showSnackBarError(
                                context, 'Please5Focuses'.tr);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          loader == true ? commonLoader() : const SizedBox()
        ],
      ),
    );
  }
}
