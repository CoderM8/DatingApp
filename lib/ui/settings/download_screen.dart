// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/setting_controllers.dart';
import 'package:eypop/back4appservice/base/api_response.dart';
import 'package:eypop/back4appservice/user_provider/wishes/download_provider_api.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:vocsy_esys_flutter_share/vocsy_esys_flutter_share.dart';

class DownloadScreen extends GetView {
  const DownloadScreen({Key? key}) : super(key: key);

  static SettingController get _settingController => Get.find<SettingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 29.w, width: 29.w),
        centerTitle: true,
        title: Styles.regular('downloads'.tr, c: ConstColors.closeColor, fs: 31.sp, ff: 'HM'),
      ),
      body: FutureBuilder<ApiResponse?>(
          future: DownloadApi.getByProfileId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(key: UniqueKey(), child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown));
            }
            if (snapshot.hasData) {
              // when user has download files update value here
              for (final ele in snapshot.data!.results ?? []) {
                _settingController.downloadTile[ele['Type']] = ele;
              }
            }
            return ListView.separated(
              key: UniqueKey(),
              padding: EdgeInsets.only(top: 5.h, bottom: 20.h),
              scrollDirection: Axis.vertical,
              physics: const ScrollPhysics(),
              separatorBuilder: (context, i) => Divider(height: 1, color: ConstColors.closeColor),
              itemCount: _settingController.downloadTile.keys.length,
              itemBuilder: (context, i) {
                final type = _settingController.downloadTile.keys.toList()[i];
                final value = _settingController.getTypes(type);
                final bool enable = (_settingController.downloadTile[type] != null);
                final parseObject = _settingController.downloadTile[type];
                return InkWell(
                  key: UniqueKey(),
                  onTap: (enable && parseObject['File'] != null)
                      ? () async {
                          final request = await HttpClient().getUrl(Uri.parse(parseObject['File'].url));
                          final response = await request.close();
                          final list = await consolidateHttpClientResponseBytes(response);
                          await VocsyShare.file('Eypop', '$type.zip', list, '*/*');
                        }
                      : null,
                  child: Container(
                    height: 80.h,
                    color: Theme.of(context).dialogBackgroundColor,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        SvgView(value['svg'], color: Theme.of(context).primaryColor, width: 28.w),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Styles.regular(value['title'], c: Theme.of(context).primaryColor, fs: 18.sp, ff: "HM"),
                              SizedBox(height: 3.h),
                              if (enable)
                                Styles.regular("${'Download_of_the'.tr} ${DateFormat('dd/MM/y', StorageService.getBox.read('languageCode')).format(parseObject['updatedAt'])}",
                                    c: ConstColors.darkGreenColor, fs: 14.sp, ff: "HB", key: UniqueKey())
                              else
                                Styles.regular('no_downloads'.tr, c: Theme.of(context).primaryColor, fs: 14.sp, key: UniqueKey()),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SvgView('assets/Icons/zip_outline.svg', color: enable ? ConstColors.darkGreenColor : ConstColors.offlineColor),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
