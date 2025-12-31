// ignore_for_file: must_be_immutable

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../Constant/Widgets/textwidget.dart';
import '../../Constant/constant.dart';
import '../../Controllers/Picture_Controller/profile_pic_controller.dart';
import '../../back4appservice/user_provider/users/provider_user_api.dart';

class ChangeLanguageScreen extends GetView {
  ChangeLanguageScreen({Key? key}) : super(key: key);
  RxInt selectedIndex = 0.obs;
  final SettingController _settingController = Get.put(SettingController());
  final PictureController _pictureController = Get.put(PictureController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 29.w, width: 29.w),
        centerTitle: true,
        title: Styles.regular('languages'.tr, c: ConstColors.closeColor, fs: 31.sp, ff: 'HM'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.only(top: 5.h),
        separatorBuilder: (context, i) => Divider(height: 1, color: ConstColors.closeColor),
        itemCount: Language.languageList().length,
        itemBuilder: (context, index) {
          if (Language.languageList()[index].languageCode == StorageService.getBox.read('languageCode')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              selectedIndex.value = index;
            });
          }
          return Obx(() {
            return ListTile(
              onTap: () async {
                selectedIndex.value = index;
                Get.updateLocale(Locale(Language.languageList()[index].languageCode));
                StorageService.getBox.write('languageCode', Language.languageList()[index].languageCode);
                QueryBuilder<ParseObject> winkGet = QueryBuilder<ParseObject>(ParseObject('WinkList'));

                final ParseResponse winkApiResponse = await winkGet.query();
                String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;
                UserLogin userLogin = UserLogin();
                userLogin.objectId = StorageService.getBox.read('ObjectId');
                userLogin.local = local;
                UserLoginProviderApi().update(userLogin);

                _pictureController.winkItems.clear();
                for (var i = 0; i < winkApiResponse.results!.length; i++) {
                  _pictureController.winkItems.add(winkApiResponse.results![i][local]);
                }
                _settingController.update();
              },
              tileColor: Theme.of(context).dialogBackgroundColor,
              title: Styles.regular(Language.languageList()[index].name, c: Theme.of(context).primaryColor, fs: 18.sp),
              leading: Styles.regular(Language.languageList()[index].flag, c: Theme.of(context).primaryColor, ff: 'RR', fs: 29.sp),
              trailing: selectedIndex.value == index ? const SvgView('assets/Icons/check.svg') : const SizedBox.shrink(),
            );
          });
        },
      ),
    );
  }
}

class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);
  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇺🇸", "English", "en"),
      Language(2, "🇪🇸", "España", "es"),
      Language(3, "🇫🇷", "Französisch", "fr"),
      Language(4, "🇵🇹", "Portuguese", "pt"),
      Language(5, "🇩🇪", "German", "de"),
      Language(6, "🇮🇹", "italian", "it"),
    ];
  }
}
