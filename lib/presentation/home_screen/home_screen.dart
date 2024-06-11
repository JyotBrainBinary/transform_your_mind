import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:transform_your_mind/core/utils/color_constant.dart';
import 'package:transform_your_mind/core/utils/dimensions.dart';
import 'package:transform_your_mind/core/utils/extension_utils.dart';
import 'package:transform_your_mind/core/utils/image_constant.dart';
import 'package:transform_your_mind/core/utils/size_utils.dart';
import 'package:transform_your_mind/core/utils/style.dart';
import 'package:transform_your_mind/presentation/home_screen/home_message_page.dart';
import 'package:transform_your_mind/presentation/home_screen/widgets/home_widget.dart';
import 'package:transform_your_mind/presentation/journal_screen/widget/my_affirmation_page.dart';
import 'package:transform_your_mind/presentation/journal_screen/widget/my_gratitude_page.dart';
import 'package:transform_your_mind/presentation/notification_screen/notification_screen.dart';
import 'package:transform_your_mind/presentation/positive_moment/positive_screen.dart';
import 'package:transform_your_mind/presentation/subscription_screen/subscription_screen.dart';
import 'package:transform_your_mind/presentation/transform_pods_screen/transform_pods_screen.dart';
import 'package:transform_your_mind/routes/app_routes.dart';
import 'package:transform_your_mind/theme/theme_controller.dart';
import 'package:transform_your_mind/widgets/common_elevated_button.dart';
import 'package:transform_your_mind/widgets/common_load_image.dart';
import 'package:transform_your_mind/widgets/custom_view_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _lottieBgController;
  String _greeting = "";
  late ScrollController scrollController = ScrollController();
  ValueNotifier<bool> showScrollTop = ValueNotifier(false);
  int? totalCountCleanse = 0;
  List<Map<String, dynamic>> quickAccessList = [
    {"title": "Motivational".tr, "icon": ImageConstant.meditationIconQuick},
    {"title": "transformPods".tr, "icon": ImageConstant.podIconQuick},
    {"title": "gratitudeJournal".tr, "icon": ImageConstant.journalIconQuick},
    {"title": "positiveMoments".tr, "icon": ImageConstant.sleepIconQuick},
  ];

  ThemeController themeController = Get.find<ThemeController>();
  List<bool> affirmationCheckList = [];
  List<bool> gratitudeCheckList = [];
  @override
  void initState() {
    getStatusBar();
    _lottieBgController = AnimationController(vsync: this);
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        _setGreetingBasedOnTime();
      },
    );
    scrollController.addListener(() {
      //scroll listener
      double showOffset = 10.0;

      if (scrollController.offset > showOffset) {
        showScrollTop.value = true;
      } else {
        showScrollTop.value = false;
      }
    });
    getAffirmationList();
    getGratitudeList();
    super.initState();
  }
  getStatusBar(){
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: ColorConstant.backGround, // Status bar background color
      statusBarIconBrightness: Brightness.dark, // Status bar icon/text color
    ));
  }

  getAffirmationList() {
    setState(() {
      affirmationCheckList = [];
    });
    List.generate(
      affirmationList.length,
      (index) => affirmationCheckList.add(false),
    );
  }

  getGratitudeList() {
    setState(() {
      gratitudeCheckList = [];
    });
    List.generate(
      gratitudeList.length,
      (index) => gratitudeCheckList.add(false),
    );
  }

  @override
  void dispose() {
    _lottieBgController.dispose();
    super.dispose();
  }

  void _setGreetingBasedOnTime() {
    setState(() {
      _greeting = _getGreetingBasedOnTime();
    });
  }

  String _getGreetingBasedOnTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 0 && hour < 12) {
      return 'goodMorning'.tr;
    } else if (hour >= 12 && hour < 17) {
      return 'goodAfternoon'.tr;
    } else if (hour >= 17 && hour < 21) {
      return 'goodEvening'.tr;
    } else {
      return 'goodNight'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ValueListenableBuilder(
        valueListenable: showScrollTop,
        builder: (context, value, child) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 700), //show/hide animation
            opacity: showScrollTop.value
                ? 1.0
                : 0.0, //set opacity to 1 on visible, or hide
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorConstant.themeColor,
              ),
              padding: const EdgeInsets.all(5.0),
              child: FloatingActionButton(
                elevation: 0.0,
                onPressed: () {
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                  );
                },
                backgroundColor: ColorConstant.themeColor,
                child: SvgPicture.asset(
                  ImageConstant.icUpArrow,
                  fit: BoxFit.fill,
                  height: Dimens.d20.h,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: ColorConstant.themeColor.withOpacity(0.1),
      body: CustomScrollViewWidget(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //__________________________ top view ____________________
                topView(),
                Dimens.d36.spaceHeight,
                //___________________________ add share view  ______________
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const HomeMessagePage();
                            },
                          ));
                        },
                        child: SvgPicture.asset(
                          ImageConstant.icAddRounded,
                          width: Dimens.d46,
                          height: Dimens.d46,
                          color: ColorConstant.themeColor,
                        ),
                      ),
                      Dimens.d15.spaceWidth,
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const HomeMessagePage();
                            },
                          ));
                        },
                        child: CircleAvatar(
                          backgroundColor: ColorConstant.themeColor,
                          radius: Dimens.d23,
                          child: SvgPicture.asset(
                            ImageConstant.icShareWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Dimens.d16.spaceHeight,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                  child: Text(
                    "$_greeting, RK!",
                    textAlign: TextAlign.center,
                    style: Style.cormorantGaramondMedium(fontSize: 22),
                  ),
                ),
                Dimens.d16.spaceHeight,

                //______________________________ TrendingThings _______________________
                trendingView(),

                Dimens.d30.spaceHeight,
                customDivider(),
                Dimens.d30.spaceHeight,


                //______________________________ ToDays Gratitude _______________________
                /*   const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TodaysGratitude(),
                ),*/
                //______________________________ yourDaily Recommendations _______________________

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                  child: Text(
                    "yourRecommendations".tr,
                    textAlign: TextAlign.center,
                    style: Style.montserratRegular(fontSize: Dimens.d22),
                  ),
                ),
                Dimens.d20.spaceHeight,
                recommendationsView(),
                Dimens.d20.spaceHeight,
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: ColorConstant.themeColor,
                    ),
                    child: Center(
                      child: Text(
                        "refreshDailyRecommendations".tr,
                        style: Style.montserratRegular(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Dimens.d20.spaceHeight,

                yourGratitude(),
                Dimens.d20.spaceHeight,

                yourAffirmation(),
                /*   //______________________________ Today's Cleanse _______________________

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                  child: Text(
                    "todayCleanse".tr,
                    textAlign: TextAlign.center,
                    style: Style.montserratRegular(fontSize: Dimens.d22),
                  ),
                ),
                Dimens.d30.spaceHeight,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CleanseButton(
                    totalCount: totalCountCleanse ?? 0,
                  ),
                ),*/
                /*    Dimens.d50.spaceHeight,
                //______________________________ yourDailyRituals _______________________
                Container(
                  decoration: BoxDecoration(
                      color: themeController.isDarkMode.value ? ColorConstant.textfieldFillColor : Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 27),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child:  TodaysRituals(
                    type: "yourDailyRituals".tr,
                  ),
                ),*/
                Dimens.d20.spaceHeight,
                /*    yourGratitude(),
                Dimens.d20.spaceHeight,*/
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                  child: Text(
                    "yourBookmarks".tr,
                    textAlign: TextAlign.center,
                    style: Style.montserratRegular(fontSize: Dimens.d22),
                  ),
                ),
                Dimens.d20.spaceHeight,

                trendingView(),
                Dimens.d30.spaceHeight,
                customDivider(),
                Dimens.d30.spaceHeight,

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                  child: Text(
                    "quickAccess".tr,
                    textAlign: TextAlign.center,
                    style: Style.montserratRegular(fontSize: Dimens.d22),
                  ),
                ),
                Dimens.d30.spaceHeight,

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            // 3 items per row
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 30,
                            mainAxisSpacing:
                                30 // Set the aspect ratio as needed
                            ),
                    itemCount: quickAccessList.length,
                    // Total number of items
                    itemBuilder: (BuildContext context, int index) {
                      // Generating items for the GridView
                      return GestureDetector(
                        onTap: () {
                          if (quickAccessList[index]["title"] ==
                              "motivational".tr) {
                            Navigator.pushNamed(context,
                                    AppRoutes.motivationalMessageScreen)
                                .then((value) {
                              setState(() {});
                            });
                          } else if (quickAccessList[index]["title"] ==
                              "transformPods".tr) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return const TransformPodsScreen();
                              },
                            )).then(
                              (value) {
                                setState(() {});
                              },
                            );
                          } else if (quickAccessList[index]["title"] ==
                              "gratitudeJournal".tr) {
                            Navigator.pushNamed(
                                    context, AppRoutes.myGratitudePage)
                                .then((value) {
                              setState(() {});
                            });
                          } else {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return const PositiveScreen();
                              },
                            )).then(
                              (value) {
                                setState(() {});
                              },
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: themeController.isDarkMode.value
                                  ? ColorConstant.textfieldFillColor
                                  : ColorConstant.themeColor.withOpacity(0.21)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                quickAccessList[index]["icon"],
                                height: 24,
                                width: 24,
                              ),
                              Dimens.d10.spaceHeight,
                              Text(
                                quickAccessList[index]["title"],
                                // Displaying item index
                                style: Style.montserratSemiBold(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Dimens.d50.spaceHeight,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.d20),
      color: ColorConstant.themeColor.withOpacity(0.2),
      height: 1,
      width: double.infinity,
    );
  }

  Widget topView() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: Dimens.d300,
              color: ColorConstant.backGround,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 40.0),
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const NotificationScreen();
                    },
                  )).then((value) {
                    setState(() {
                      getStatusBar();
                    });
                  },);
                },
                child: SvgPicture.asset(
                  height: 25.h,
                  ImageConstant.notification,
                ),
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset(
              ImageConstant.transformYour,
              fit: BoxFit.cover,
            ),
            Positioned(
              left: Dimens.d50,
              right: Dimens.d50,
              top: Dimens.d45.h,
              bottom: Dimens.d15,
              child: Center(
                child: AutoSizeText(
                  "“Calm mind brings inner strength and self-confidence, so that's very important for good health” ",
                  textAlign: TextAlign.center,
                  wrapWords: false,
                  maxLines: 4,
                  style: Style.montserratRegular(
                      fontSize: Dimens.d17, color: ColorConstant.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget trendingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(10, (index) {
              return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return SubscriptionScreen(
                          skip: false,
                        );
                      },
                    ));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: BookmarkListTile(),
                  ));
            }),
          ),
        ),
        // Dimens.d80.spaceHeight,
      ],
    );
  }

  Widget recommendationsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        //itemCount:yourDailyRecommendations.length,
        itemCount: 5,

        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Container(
              height: Dimens.d100.h,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: themeController.isDarkMode.value ? ColorConstant.textfieldFillColor : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 0),
                    // Specify the offset of the shadow
                    blurRadius: 4,
                    // Specify the blur radius
                    spreadRadius: 0, // Specify the spread radius
                  ),
                ],
              ),
              child: Row(children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CachedNetworkImage(
                      height: Dimens.d80.h,
                      width: Dimens.d80,
                      imageUrl: "https://picsum.photos/250?image=9",
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => PlaceHolderCNI(
                        height: Dimens.d80.h,
                        width: Dimens.d80,
                        borderRadius: 10.0,
                      ),
                      errorWidget: (context, url, error) => PlaceHolderCNI(
                        height: Dimens.d80.h,
                        width: Dimens.d80,
                        isShowLoader: false,
                        borderRadius: 8.0,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(6.0),
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      child: Center(
                          child: Image.asset(
                        ImageConstant.lockHome,
                        height: 5,
                        width: 5,
                      )),
                    )
                  ],
                ),
                Dimens.d25.spaceWidth,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "meditationMin".tr,
                      style: Style.montserratRegular(
                          fontSize: 8,),
                    ),
                    Dimens.d7.spaceHeight,
                    SizedBox(
                      width: Dimens.d200,
                      child: Text(
                        "cormorantMedium".tr,
                        maxLines: 2,
                        style: Style.montserratRegular(
                          fontSize: 15,

                        ),
                      ),
                    ),
                    Dimens.d7.spaceHeight,
                    Text(
                      "Ravi K",
                      style: Style.montserratRegular(
                          fontSize: 8,),
                    ),
                  ],
                )
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget yourAffirmation() {

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
            child: Text(
              "today'sAffirmation".tr,
              textAlign: TextAlign.center,
              style: Style.montserratRegular(fontSize: Dimens.d22),
            ),
          ),
          Dimens.d20.spaceHeight,
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: ColorConstant.white,
                boxShadow: [
                  BoxShadow(
                    color: ColorConstant.black.withOpacity(0.1),
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                    spreadRadius: 0, // Specify the spread radius
                  )
                ]),
            child: affirmationList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Dimens.d10.spaceHeight,
                        Text(
                          "WellDone"
                              .tr,
                          textAlign: TextAlign.center,
                          style: Style.montserratRegular(
                              color: ColorConstant.black),
                        ),
                        Dimens.d20.spaceHeight,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CommonElevatedButton(
                            title: "addNew".tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.myAffirmationPage)!.then(
                                (value) {
                                  setState(() {
                                    getAffirmationList();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Dimens.d10.spaceHeight,
                      ],
                    ),
                  )
                : Column(
                  children: [
                    ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: affirmationList.length,
                                  itemBuilder: (context, index) {
                    return InkWell(
                    onTap: () {
                      setState(() {
                                affirmationCheckList[index] = true;
                                Future.delayed(const Duration(milliseconds: 800)).then(
                                  (value) {
                                    setState(() {
                                      affirmationList.removeAt(index);
                                      getAffirmationList();
                                    });
                                  },
                                );
                              });
                            },
                            child: ListTile(
                              title: Text(
                                affirmationList[index]["title"],
                                style: Style.montserratRegular(),
                              ),
                              trailing: affirmationCheckList[index] == true
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorConstant.themeColor),
                                      child: Center(
                                          child: SvgPicture.asset(ImageConstant.checkBox)
                                      ),
                                    )
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: ColorConstant.themeColor)),
                                    ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    Dimens.d20.spaceHeight,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: CommonElevatedButton(
                        title: "addNew".tr,
                        onTap: () {
                          Get.toNamed(AppRoutes.myAffirmationPage)!.then(
                                (value) {
                              setState(() {
                                getAffirmationList();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Dimens.d20.spaceHeight,

                  ],
                ),
          )
        ],
      ),
    );
  }

  Widget yourGratitude() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimens.d20),
            child: Text(
              "today'sGratitude".tr,
              textAlign: TextAlign.center,
              style: Style.montserratRegular(fontSize: Dimens.d22),
            ),
          ),
          Dimens.d20.spaceHeight,
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: ColorConstant.white,
                boxShadow: [
                  BoxShadow(
                    color: ColorConstant.black.withOpacity(0.1),
                    offset: const Offset(0, 0),
                    blurRadius: 4,
                    spreadRadius: 0, // Specify the spread radius
                  )
                ]),
            child: gratitudeList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Dimens.d10.spaceHeight,
                        Text(
                          "Well done, you completed all your Gratitude today."
                              .tr,
                          textAlign: TextAlign.center,
                          style: Style.montserratRegular(
                              color: ColorConstant.black),
                        ),
                        Dimens.d20.spaceHeight,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CommonElevatedButton(
                            title: "addNew".tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.myGratitudePage)!.then(
                                (value) {
                                  setState(() {
                                    getGratitudeList();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Dimens.d10.spaceHeight,
                      ],
                    ),
                  )
                : Column(
                  children: [
                    ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gratitudeList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                gratitudeCheckList[index] = true;
                                Future.delayed(const Duration(milliseconds: 800)).then(
                                  (value) {
                                    setState(() {
                                      gratitudeList.removeAt(index);
                                      getGratitudeList();
                                    });
                                  },
                                );
                              });
                            },
                            child: ListTile(
                              title: Text(
                                gratitudeList[index]["title"],
                                style: Style.montserratRegular(),
                              ),
                              trailing: gratitudeCheckList[index] == true
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorConstant.themeColor),
                                      child:  Center(
                                        child: SvgPicture.asset(ImageConstant.checkBox)
                                      ),
                                    )
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: ColorConstant.themeColor)),
                                    ),
                            ),
                          );
                                  },
                                  separatorBuilder: (context, index) {
                    return const Divider();
                                  },
                                ),
                    Dimens.d20.spaceHeight,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: CommonElevatedButton(
                        title: "addNew".tr,
                        onTap: () {
                          Get.toNamed(AppRoutes.myGratitudePage)!.then(
                                (value) {
                              setState(() {
                                getGratitudeList();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Dimens.d20.spaceHeight,

                  ],
                ),
          )
        ],
      ),
    );
  }
}

