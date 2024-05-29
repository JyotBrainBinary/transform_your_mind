import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transform_your_mind/core/app_export.dart';
import 'package:transform_your_mind/core/common_widget/layout_container.dart';
import 'package:transform_your_mind/core/common_widget/snack_bar.dart';
import 'package:transform_your_mind/core/utils/color_constant.dart';
import 'package:transform_your_mind/core/utils/dimensions.dart';
import 'package:transform_your_mind/core/utils/extension_utils.dart';
import 'package:transform_your_mind/core/utils/image_constant.dart';
import 'package:transform_your_mind/core/utils/image_utills.dart';
import 'package:transform_your_mind/presentation/home_screen/widgets/add_image_gratitude.dart';
import 'package:transform_your_mind/presentation/journal_screen/widget/my_gratitude_page.dart';
import 'package:transform_your_mind/widgets/common_elevated_button.dart';
import 'package:transform_your_mind/widgets/common_text_field.dart';
import 'package:transform_your_mind/widgets/custom_appbar.dart';
import 'package:transform_your_mind/widgets/image_picker_action_sheet.dart';

import '../../../core/utils/style.dart';


class AddGratitudePage extends StatefulWidget {
  const AddGratitudePage({
    Key? key,
    this.isSaved,  this.isFromMyGratitude,
  }) : super(key: key);
  static const addGratitude = '/addGratitude';

  final bool? isFromMyGratitude;
  final bool? isSaved;
  @override
  State<AddGratitudePage> createState() => _AddGratitudePageState();
}

class _AddGratitudePageState extends State<AddGratitudePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final FocusNode titleFocus = FocusNode();
  final FocusNode descFocus = FocusNode();
  ValueNotifier<XFile?> imageFile = ValueNotifier(null);
  int maxLength = 50;
  int maxLengthDesc = 2000;
  ValueNotifier<int> currentLength = ValueNotifier(0);
  String? urlImage;
  bool _isImageRemoved = false;
  int gratitudeAddedCount = 0;

  File? selectedImage;
  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: "Add Gratitude",
     /*   title: widget.gratitudeData != null
            ? i10n.editGratitude
            : i10n.addGratitude,*/
        action: !(widget.isFromMyGratitude!)
            ? Row(children: [
                GestureDetector(
                    onTap: () {
      /*                dashboardBloc.add(UpdateOnboardingStepEvent(
                          request: OnboardingStep(onBoardStep: 5)));
                      Navigator.pushNamedAndRemoveUntil(
                          context, AddGoalsPage.addGoals, (route) => false,
                          arguments: {AppConstants.isFromMyGoals: false});*/
                    },
                    child: const Text("Skip")),
                Dimens.d20.spaceWidth,
              ])
            : /*widget.gratitudeData != null
                ? LottieIconButton(
                    icon: AppAssets.lottieDeleteAccount,
                    onTap: () {
                      _gratitudeBloc.add(
                        DeleteGratitudeEvent(
                            deleteGratitudeRequest: DeleteGratitudeRequest(
                                userGratitudeId:
                                    widget.gratitudeData?.userGratitudeId ??
                                        ""),
                            isFromDraft: true),
                      );
                    },
                  )
                :*/ const SizedBox.shrink(),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: LayoutContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Dimens.d10.spaceHeight,
                          ValueListenableBuilder(
                            valueListenable: imageFile,
                            builder: (context, value, child) {
                              return AddGratitudeImageWidget(
                                onTap: () async {
                                  await showImagePickerActionSheet(context)
                                      ?.then((value) async {
                                    if (value != null) {
                                      imageFile.value =
                                      await ImageUtils.compressImage(
                                          value);
                                      imageFile.value = value;
                                    }
                                  });
                                },
                                onDeleteTap: () async {

                                  imageFile = ValueNotifier(null);
                                  urlImage = null;
                                  _isImageRemoved = true;
                                  setState(() {

                                  });
                                 /* _gratitudeBloc
                                      .add(RefreshGratitudeEvent());*/
                                },
                                image: imageFile.value,
                                imageURL: urlImage,
                              );
                            },
                          ),
                          Dimens.d20.spaceHeight,
                          CommonTextField(
                            hintText: "Enter Title",
                            labelText: "Title",
                            controller: titleController,
                            focusNode: titleFocus,
                            nextFocusNode: descFocus,
                            prefixLottieIcon: ImageConstant.lottieTitle,
                            maxLength: maxLength,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(maxLength),
                            ],
                          ),
                          Dimens.d16.spaceHeight,
                          CommonTextField(
                            hintText: "Enter Description",
                            labelText: "Description",
                            controller: descController,
                            focusNode: descFocus,
                            transform:
                            Matrix4.translationValues(0, -108, 0),
                            prefixLottieIcon:
                            ImageConstant.lottieDescription,
                            maxLines: 15,
                            maxLength: maxLengthDesc,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                  maxLengthDesc),
                            ],
                            onChanged: (value) {
                              currentLength.value =
                                  descController.text.length;
                            },
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                          Dimens.d20.spaceHeight,
                        ],
                      ),
                    ),
                  ),
                ),

                ///buttons
                LayoutContainer(
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonElevatedButton(
                          title:"Draft",
                          outLined: true,
                          textStyle: Style.montserratRegular(
                              color: ColorConstant.textDarkBlue),
                          onTap: () async {
                            if (titleController.text.trim().isEmpty) {
                              showSnackBarError(context, "Empty Title");
                            } else if (descController.text.trim().isEmpty) {
                              showSnackBarError(
                                  context, "Empty Description");
                            } else {
                              gratitudeDraftList.add({
                                "title":titleController.text,
                                "des":descController.text,
                                "image":imageFile.value,
                                "createdOn":"",
                              });
                              setState(() {
                              });
                              Get.back();
                            /*  _gratitudeBloc.add(
                                AddGratitudeEvent(
                                  addGratitudeRequest: AddGratitudeRequest(
                                      userGratitudeId: widget
                                          .gratitudeData?.userGratitudeId,
                                      title: titleController.text.trim(),
                                      description:
                                      descController.text.trim(),
                                      imageUrl: (imageFile.value != null)
                                          ? 'image/${imageFile.value?.path.fileExtension ?? ''}'
                                          : '',
                                      imageFilePath: selectedImage?.path,
                                      isSaved: false,
                                      isImageDeleted:
                                      (imageFile.value != null)
                                          ? false
                                          : _isImageRemoved),
                                ),
                              );*/
                            }
                          },
                        ),
                      ),
                      Dimens.d20.spaceWidth,
                      Expanded(
                        child: CommonElevatedButton(
                          title: "Save",
                          onTap: () async {
                            if (titleController.text.trim().isEmpty) {
                              showSnackBarError(context, "Empty Title");
                            } else if (descController.text.trim().isEmpty) {
                              showSnackBarError(
                                  context, "Empty Description");
                            } else {
                              gratitudeList.add({
                                "title":titleController.text,
                                "des":descController.text,
                                "image":imageFile.value,
                                "createdOn":"",
                              });
                              setState(() {

                              });
                              Get.back();
                           /*   _gratitudeBloc.add(
                                AddGratitudeEvent(
                                  addGratitudeRequest: AddGratitudeRequest(
                                      userGratitudeId: widget
                                          .gratitudeData?.userGratitudeId,
                                      title: titleController.text.trim(),
                                      description:
                                      descController.text.trim(),
                                      imageUrl: (imageFile.value != null)
                                          ? 'image/${imageFile.value?.path.fileExtension ?? ''}'
                                          : '',
                                      imageFilePath: selectedImage?.path,
                                      isSaved: true,
                                      isImageDeleted:
                                      (imageFile.value != null)
                                          ? false
                                          : _isImageRemoved),
                                ),
                              );*/
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Dimens.d10.spaceHeight,
              ],
            ),
       /*     if (state is GratitudeLoadingState)
              Container(
                color: Colors.transparent,
                child: Center(
                  child: InkDropLoader(
                    size: Dimens.d50,
                    color: ColorConstant.themeColor,
                  ),
                ),
              )*/
          ],
        );
      }),
    );
  }
}