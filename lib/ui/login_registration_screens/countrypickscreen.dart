import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/authentication_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CountryPick extends StatelessWidget {
  CountryPick({Key? key}) : super(key: key);
  final AuthController _authController = Get.find<AuthController>();
  final UserController _userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: ConstColors.white,
        elevation: 0.3,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: ConstColors.themeColor,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.arrow_back_ios)),
          ],
        ),
        leadingWidth: 56.w,
        titleSpacing: 0,
        title: InkWell(onTap: () => Get.back(), child: Styles.regular('country_code'.tr, ff: 'RR', fs: 20.sp)),
      ),
      body: _authController.apiResponse != null && _authController.apiResponse!.results != null
          ? ListView.separated(
              itemCount: _authController.apiResponse!.results!.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  leading: Styles.regular(_authController.apiResponse!.results![index]['DialCode'], fs: 18.sp, c: Theme.of(context).primaryColor),
                  title: Styles.regular(_authController.apiResponse!.results![index]['Name'], fs: 18.sp, c: Theme.of(context).primaryColor, ff: 'RB'),
                  onTap: () {
                    _userController.countryCodeNumber.value = _authController.apiResponse!.results![index]['DialCode'];
                    Get.back();
                  },
                );
              },
            )
          : Center(child: CircularProgressIndicator(color: ConstColors.themeColor)),
    );
  }
}
