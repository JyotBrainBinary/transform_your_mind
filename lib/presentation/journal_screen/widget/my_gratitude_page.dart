import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:transform_your_mind/core/app_export.dart';
import 'package:transform_your_mind/core/common_widget/layout_container.dart';
import 'package:transform_your_mind/core/common_widget/snack_bar.dart';
import 'package:transform_your_mind/core/service/pref_service.dart';
import 'package:transform_your_mind/core/utils/color_constant.dart';
import 'package:transform_your_mind/core/utils/dimensions.dart';
import 'package:transform_your_mind/core/utils/end_points.dart';
import 'package:transform_your_mind/core/utils/extension_utils.dart';
import 'package:transform_your_mind/core/utils/image_constant.dart';
import 'package:transform_your_mind/core/utils/prefKeys.dart';
import 'package:transform_your_mind/core/utils/size_utils.dart';
import 'package:transform_your_mind/core/utils/style.dart';
import 'package:transform_your_mind/model_class/common_model.dart';
import 'package:transform_your_mind/model_class/gratitude_model.dart';
import 'package:transform_your_mind/presentation/journal_screen/widget/add_gratitude_page.dart';
import 'package:transform_your_mind/presentation/journal_screen/widget/journal_list_tile_layout.dart';
import 'package:transform_your_mind/presentation/journal_screen/widget/journal_shimmer_widget.dart';
import 'package:transform_your_mind/routes/app_routes.dart';
import 'package:transform_your_mind/theme/theme_controller.dart';
import 'package:transform_your_mind/widgets/common_elevated_button.dart';
import 'package:transform_your_mind/widgets/common_text_field.dart';
import 'package:transform_your_mind/widgets/custom_appbar.dart';



class MyGratitudePage extends StatefulWidget {
  final bool fromNotification;

  const MyGratitudePage({
    super.key,
    this.fromNotification = false,
  });

  @override
  State<MyGratitudePage> createState() => _MyGratitudePageState();
}

class _MyGratitudePageState extends State<MyGratitudePage> {
  TextEditingController dateController = TextEditingController();
  FocusNode dateFocus = FocusNode();
  List gratitudeList = [];
  List categoryList = [];

  bool _isLoading = false;
  bool _isLoadingDraft = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _refreshControllerDrafts =
      RefreshController(initialRefresh: false);
  int pageNumber = 1;
  int pageNumberDrafts = 1;
  int totalItemCountOfGratitude = 0;
  int totalItemCountOfGratitudeDrafts = 0;
  Timer? _debounce;
  bool _isSearching = false;
  ThemeController themeController = Get.find<ThemeController>();
  DateTime _currentDate = DateTime.now();
  bool select = false;
  ValueNotifier selectedCategory = ValueNotifier(null);
  FocusNode searchFocus = FocusNode();
  TextEditingController searchController = TextEditingController();
  List? _filteredBookmarks;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: ColorConstant.backGround, // Status bar background color
      statusBarIconBrightness: Brightness.dark, // Status bar icon/text color
    ));
    getGratitude();
    super.initState();
  }

  searchBookmarks(String query, List bookmarks) {
    return bookmarks
        .where((bookmark) =>
            bookmark.name!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  GratitudeModel gratitudeModel = GratitudeModel();
  CommonModel commonModel = CommonModel();
  bool loader = false;
  getGratitude() async {
    setState(() {
      loader = true;
    });
    var headers = {
      'Authorization': 'Bearer ${PrefService.getString(PrefKey.token)}'
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            '${EndPoints.baseUrl}get-gratitude?created_by=${PrefService.getString(PrefKey.userId)}&date=${dateController.text}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      gratitudeModel = GratitudeModel();
      final responseBody = await response.stream.bytesToString();
      gratitudeModel = gratitudeModelFromJson(responseBody);
      gratitudeList = gratitudeModel.data!;
      categoryList = [];
      for (int i = 0; i < gratitudeList.length; i++) {
        categoryList.add(gratitudeList[i].name);
      }
      debugPrint("gratitude Model $gratitudeList");
      debugPrint("gratitude Model ${gratitudeModel.data}");
      setState(() {
        loader = false;
      });
      setState(() {});
    } else {
      setState(() {
        loader = false;
      });
      debugPrint(response.reasonPhrase);
    }
  }

  deleteGratitude(id) async {
    setState(() {
      loader = true;
    });
    var headers = {
      'Authorization': 'Bearer ${PrefService.getString(PrefKey.token)}'
    };
    var request = http.Request(
        'DELETE', Uri.parse('${EndPoints.baseUrl}delete-gratitude?id=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      commonModel = commonModelFromJson(responseBody);
      showSnackBarSuccess(context, commonModel.message ?? "");
    } else {
      debugPrint(response.reasonPhrase);
    }
  }

  getFilterData() {
    gratitudeList = gratitudeModel.data!
        .where((item) => item.name == selectedCategory.value)
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          select = false;
        });
      },
      child: Scaffold(
          backgroundColor: themeController.isDarkMode.value
              ? ColorConstant.black
              : ColorConstant.backGround,
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            title: "myGratitude".tr,
            showBack: true,
            action: Padding(
              padding: const EdgeInsets.only(right: Dimens.d20),
              child: GestureDetector(
                onTap: () {
                  selectedCategory = ValueNotifier(null);
                  _onAddClick(context);
                },
                child: SvgPicture.asset(
                  ImageConstant.addTools,
                  height: Dimens.d22,
                  width: Dimens.d22,
                ),
              ),
            ),
            onTap: () {
              if (widget.fromNotification) {
                Get.toNamed(AppRoutes.dashBoardScreen);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          body: Stack(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Dimens.d30.spaceHeight,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimens.d30),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      select = !select;
                                    });
                                  },
                                  child: CommonTextField(
                                      enabled: false,
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(13.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              select = !select;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                              ImageConstant.calendar),
                                        ),
                                      ),
                                      hintText: "DD/MM/YYYY",
                                      controller: dateController,
                                      focusNode: dateFocus),
                                ),
                              ),
                              Dimens.d20.spaceHeight,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    _buildCategoryDropDown(context),
                                    Dimens.d10.spaceWidth,
                                    Expanded(
                                      child: Container(
                                        height: 38,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorConstant.colorBFD0D4
                                                  .withOpacity(0.5),
                                              blurRadius: 8.0,
                                              spreadRadius:
                                                  0.5, // Spread the shadow slightly
                                            ),
                                          ],
                                        ),
                                        child: CommonTextField(
                                          hintText: "search".tr,
                                          controller: searchController,
                                          focusNode: searchFocus,
                                          prefixLottieIcon:
                                              ImageConstant.lottieSearch,
                                          textInputAction: TextInputAction.done,
                                          onChanged: (value) async {
                                            if (value.isEmpty) {
                                              await getGratitude();
                                            } else {
                                              gratitudeList = searchBookmarks(
                                                  value, gratitudeList);
                                            }
                                            setState(()  {

                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// saved list
                              Expanded(
                                child: (_isLoading &&
                                        (pageNumber == 1) &&
                                        !_isSearching)
                                    ? const JournalListShimmer()
                                    : (gratitudeList.isNotEmpty)
                                        ? LayoutContainer(
                                            child: ListView.builder(
                                              itemCount: gratitudeList.length,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                var data = gratitudeList[index];
                                                return JournalListTileLayout(
                                                  description: data.description,
                                                  onDeleteTapCallback: () {
                                                    _showAlertDialogDelete(
                                                        context,
                                                        index,
                                                        data.id);
                                                    setState(() {});
                                                  },
                                                  onEditTapCallback: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                      builder: (context) {
                                                        return AddGratitudePage(
                                                          categoryList:
                                                              categoryList,
                                                          id: data.id,
                                                          description:
                                                              data.description,
                                                          title: data.name,
                                                          date:
                                                              data.createdAt ??
                                                                  '',
                                                          edit: true,
                                                          isFromMyGratitude:
                                                              true,
                                                          registerUser: false,
                                                          isSaved: true,
                                                        );
                                                      },
                                                    )).then(
                                                      (value) async {
                                                        if (value != null &&
                                                            value is bool) {
                                                          _refreshGratitudeList(
                                                              value);
                                                        }
                                                        await getGratitude();
                                                        setState(() {});
                                                      },
                                                    );
                                                  },
                                                  margin: EdgeInsets.only(
                                                      bottom: Dimens.d20.h),
                                                  title: data.name ?? '',
                                                  //image: data["image"] ?? '',
                                                  image:
                                                      "https://picsum.photos/250?image=9" ??
                                                          '',
                                                  createdDate: data.date ?? '',
                                                );
                                              },
                                            ),
                                          )
                                        : _isLoadingDraft
                                            ? const SizedBox.shrink()
                                            : gratitudeList.isEmpty
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom:
                                                                Dimens.d150),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SvgPicture.asset(
                                                            ImageConstant
                                                                .noData),
                                                        Dimens.d20.spaceHeight,
                                                        Text(
                                                          "dataNotFound".tr,
                                                          style: Style
                                                              .montserratBold(
                                                                  fontSize: 24),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              if (select == true)
                Padding(
                  padding: const EdgeInsets.only(top: Dimens.d100),
                  child: widgetCalendar(),
                ),
            ],
          )),
    );
  }

  void _showAlertDialogDelete(BuildContext context, int index, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0), // Set border radius
          ),
          actions: <Widget>[
            Dimens.d18.spaceHeight,
            Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset(
                      ImageConstant.close,
                    ))),
            Center(
                child: SvgPicture.asset(
              ImageConstant.deleteAffirmation,
              height: Dimens.d96,
              width: Dimens.d96,
            )),
            Dimens.d20.spaceHeight,
            Center(
              child: Text(
                  textAlign: TextAlign.center,
                  "areYouSureDeleteGratitude".tr,
                  style: Style.montserratRegular(
                    fontSize: Dimens.d14,
                  )),
            ),
            Dimens.d24.spaceHeight,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CommonElevatedButton(
                  height: 33,
                  contentPadding: const EdgeInsets.symmetric(horizontal: Dimens.d28),

                  textStyle: Style.montserratRegular(
                      fontSize: Dimens.d12, color: ColorConstant.white),
                  title: "delete".tr,
                  onTap: () async {
                  setState(() {
                    gratitudeList = [];
                  });
                    await deleteGratitude(id);
                    await getGratitude();
                    getFilterData();
                    setState(() {});
                    Get.back();
                  },
                ),
                Container(
                  height: 33,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 21,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      border: Border.all(color: ColorConstant.themeColor)),
                  child: Center(
                    child: Text(
                      "cancel".tr,
                      style: Style.montserratRegular(fontSize: 14),
                    ),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  void _onAddClick(BuildContext context) {
    _currentDate = DateTime.now();
    final subscriptionStatus = "SUBSCRIBED";

    /// to check if item counts are not more then the config count in case of no subscription
    if (!(subscriptionStatus == "SUBSCRIBED" ||
        subscriptionStatus == "SUBSCRIBED")) {
      /*   Navigator.pushNamed(context, SubscriptionPage.subscription, arguments: {
        AppConstants.isInitialUser: AppConstants.noSubscription,
        AppConstants.subscriptionMessage: i10n.journalNoSubscriptionMessage,
      });*/
    } else {
      dateController.clear();
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return AddGratitudePage(
            categoryList: categoryList,
            isFromMyGratitude: true,
            registerUser: false,
          );
        },
      )).then(
        (value) async {
          await getGratitude();
          setState(() {});
        },
      );
    }
  }

  void _refreshGratitudeList(bool isSaved) {
    pageNumber = 1;

    pageNumberDrafts = 1;

  }



  Widget widgetCalendar() {
    return Container(
        height: 350,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: themeController.isDarkMode.isTrue
              ? ColorConstant.textfieldFillColor
              : ColorConstant.white,
        ),
        child: CalendarCarousel<Event>(
          onDayPressed: (DateTime date, List<Event> events) async {
            if (date.isBefore(DateTime.now())) {
              setState.call(() => _currentDate = date);

              debugPrint("==========$_currentDate");
              setState.call(() {
                dateController.text = DateFormat('dd/MM/yyyy').format(date);
                select = false;
              });
              await getGratitude();

              setState((){});
            }

          },

          weekendTextStyle: Style.montserratRegular(
              fontSize: 15,
              color: themeController.isDarkMode.isTrue
                  ? ColorConstant.white
                  : ColorConstant.black),
          // Customize your text style
          thisMonthDayBorderColor: Colors.transparent,
          customDayBuilder: (
              bool isSelectable,
              int index,
              bool isSelectedDay,
              bool isToday,
              bool isPrevMonthDay,
              TextStyle textStyle,
              bool isNextMonthDay,
              bool isThisMonthDay,
              DateTime day,
              ) {
            if (day.isAfter(DateTime.now())) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: Dimens.d32,
                width: Dimens.d32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: Style.montserratRegular(
                        fontSize: 15,
                        color: Colors
                            .grey), // Customize your future day text style
                  ),
                ),
              );
            } else if (isSelectedDay) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: Dimens.d32,
                width: Dimens.d32,
                decoration: BoxDecoration(
                  color: ColorConstant.themeColor,
                  // Customize your selected day color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: Style.montserratRegular(
                        fontSize: 15,
                        color: ColorConstant
                            .white), // Customize your selected day text style
                  ),
                ),
              );
            } else {
              return null;
            }
          },
          weekFormat: false,
          daysTextStyle: Style.montserratRegular(
              fontSize: 15,
              color: themeController.isDarkMode.isTrue
                  ? ColorConstant.white
                  : ColorConstant.black),
          height: 300.0,
          markedDateIconBorderColor: Colors.transparent,
          childAspectRatio: 1.5,
          dayPadding: 0.0,
          prevDaysTextStyle: Style.montserratRegular(fontSize: 15),
          selectedDateTime: _currentDate,
          headerTextStyle: Style.montserratRegular(
              color: themeController.isDarkMode.isTrue
                  ? ColorConstant.white
                  : ColorConstant.black,
              fontWeight: FontWeight.bold),
          dayButtonColor: themeController.isDarkMode.isTrue
              ? ColorConstant.textfieldFillColor
              : Colors.white,
          weekDayBackgroundColor: themeController.isDarkMode.isTrue
              ? ColorConstant.textfieldFillColor
              : Colors.white,
          markedDateMoreCustomDecoration: BoxDecoration(
              color: themeController.isDarkMode.isTrue
                  ? ColorConstant.black
                  : Colors.white),
          shouldShowTransform: false,
          staticSixWeekFormat: false,
          weekdayTextStyle: Style.montserratRegular(
              fontSize: 11,
              color: themeController.isDarkMode.isTrue
                  ? ColorConstant.white
                  : ColorConstant.color797B86,
              fontWeight: FontWeight.bold),
          todayButtonColor: Colors.transparent,
          selectedDayBorderColor: Colors.transparent,
          todayBorderColor: Colors.transparent,
          selectedDayButtonColor: Colors.transparent,
          daysHaveCircularBorder: false,
          todayTextStyle: Style.montserratRegular(
              fontSize: 15,
              color: themeController.isDarkMode.isTrue
                  ? ColorConstant.white
                  : ColorConstant.black),
        ));
  }

  Widget _buildCategoryDropDown(BuildContext context) {
    return Expanded(
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: ColorConstant.lightGrey),
          borderRadius: BorderRadius.circular(30),
          color: ColorConstant.themeColor,
        ),
        child: DropdownButton(
          value: selectedCategory.value,
          borderRadius: BorderRadius.circular(30),
          onChanged: (value) async {
            {
              setState(() {
                selectedCategory.value = value;
              });
              getFilterData();
              setState(() {});
            }
          },
          selectedItemBuilder: (_) {
            return categoryList.map<Widget>((item) {
              bool isSelected = selectedCategory.value == item;
              return Padding(
                padding: const EdgeInsets.only(left: 18, top: 8),
                child: Text(
                  item ?? '',
                  maxLines: 1,
                  style: Style.montserratRegular(
                    fontSize: Dimens.d14,
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },
          style: Style.montserratRegular(
            fontSize: Dimens.d14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          hint: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              "selectCategory".tr,
              style: Style.montserratRegular(
                  fontSize: Dimens.d14, color: Colors.white),
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SvgPicture.asset(
              ImageConstant.icDownArrow,
              height: 20,
              color: Colors.white,
            ),
          ),
          elevation: 16,
          itemHeight: 50,
          menuMaxHeight: 350.h,
          underline: const SizedBox(
            height: 0,
          ),
          isExpanded: true,
          dropdownColor: ColorConstant.themeColor,
          items: categoryList.map<DropdownMenuItem>((item) {
            bool isSelected = selectedCategory.value == item;
            return DropdownMenuItem(
              value: item,
              child: AnimatedBuilder(
                animation: selectedCategory,
                builder: (BuildContext context, Widget? child) {
                  return child!;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    item ?? '',
                    style: Style.montserratRegular(
                      fontSize: Dimens.d14,
                      color: ColorConstant.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
