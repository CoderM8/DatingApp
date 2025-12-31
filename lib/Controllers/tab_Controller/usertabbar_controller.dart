import 'package:get/get.dart';

class UserTabController extends GetxController with GetSingleTickerProviderStateMixin {
  RxInt selectedIndex = 0.obs;
  // TabController? tabController;

  // ScrollController? scrollController;
  // scrollListener() {}

    // @override
    // void onInit() {
    //   super.onInit();
    // controller = TabController(vsync: this, length: 2);
    // controller.index = 0;
    // controller!.addListener(() {
    //   selectedIndex.value = controller!.index;
    // });
    // scrollController = ScrollController();

    // scrollController!.addListener(scrollListener);
    // tabController = TabController(length: 2, vsync: this);
    // tabController!.index = 0;
    // tabController!.addListener(_smoothScrollToTop);
    // }

  // _smoothScrollToTop() {
  //   scrollController!.animateTo(
  //     0,
  //     duration: const Duration(microseconds: 300),
  //     curve: Curves.ease,
  //   );
  //   selectedIndex.value = tabController!.index;
  // }

  // @override
  // void onClose() {
  // controller!.dispose();
  // tabController!.dispose();
  // super.onClose();
  // }
}
