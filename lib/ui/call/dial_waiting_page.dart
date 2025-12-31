import 'package:cached_network_image/cached_network_image.dart';
import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/back4appservice/user_provider/pair_notification_provider_api/pair_notification_provider_api.dart';
import 'package:eypop/models/new_notification/new_notification_pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DialWaitingPage extends StatelessWidget {
  const DialWaitingPage({Key? key, required this.img, required this.name, required this.pairNotificationsId}) : super(key: key);
  final String img;
  final String name;
  final String pairNotificationsId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GradientWidget(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: img,
                useOldImageOnUrlChange: true,
                height: 120.w,
                width: 120.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => ClipOval(child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover)),
                errorWidget: (context, url, error) => ClipOval(child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover)),
              ),
            ),
            SizedBox(height: 11.h),
            Styles.regular(name, c: Theme.of(context).primaryColor, ff: "HB", fs: 20.sp),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Styles.regular("User_busy".tr, fs: 18, al: TextAlign.center, c: ConstColors.redColor),
            ),
            const Spacer(),
            // CALL END
            SvgView(
              'assets/Icons/call_end.svg',
              height: 84.12.w,
              width: 84.12.w,
              fit: BoxFit.cover,
              onTap: () async {
                Get.back();
                final PairNotifications pairNotifications = PairNotifications();
                pairNotifications.objectId = pairNotificationsId;
                pairNotifications["busy"] = true;
                await PairNotificationProviderApi().update(pairNotifications);
              },
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
