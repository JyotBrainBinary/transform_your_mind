
import 'package:get/get.dart';
import 'package:transform_your_mind/presentation/today_cleanse_screen/cleanse_controller.dart';

/// A binding class for the SplashScreen.
///
/// This class ensures that the SplashController is created when the
/// SplashScreen is first loaded.
class CleanseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CleanseController());
  }
}
