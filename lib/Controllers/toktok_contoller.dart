import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/back4appservice/user_provider/wishes/toktok_provider_api.dart';
import 'package:eypop/back4appservice/user_provider/wishes/wish_provider_api.dart';
import 'package:eypop/models/wishes_model/toktok_model.dart';
import 'package:eypop/models/wishes_model/wish_model.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TokTokController extends GetxController {
  final RxList tokTokTotalImage = [].obs;
  final RxList tokTokTotalVideo = [].obs;
  final RxBool isProcessing = false.obs;
  final RxString tokTokObjectId = ''.obs;

  final RxList seeTokTok = [].obs;
  TokTokModel tokTokObject = TokTokModel();

  @override
  Future<void> onInit() async {
    await getAllWishByProfile();
    super.onInit();
  }

  Future getAllWishByProfile() async {
    if (StorageService.getBox.read('DefaultProfile') != null) {
      await WishesApi().getProfileWishByIdType(profileId: StorageService.getBox.read('DefaultProfile')).then((value) {
        tokTokTotalImage.clear();
        tokTokTotalVideo.clear();
        if (value != null) {
          for (final WishModel ele in value.results ?? []) {
            if (ele.postType.contains('Image') && ele['Img_Post'] != null) {
              if (ele['Img_Post']['Status'] == true) {
                tokTokTotalImage.add({"Users_Wish": ele.objectId, "Img_Post": ele['Img_Post']['objectId']});
              }
            } else if (ele.postType.contains('Video') && ele['Video_Post'] != null) {
              if (ele['Video_Post']['Status'] == true) {
                tokTokTotalVideo.add({"Users_Wish": ele.objectId, "Video_Post": ele['Video_Post']['objectId']});
              }
            }
          }
        }
      });
      if (kDebugMode) {
        print('Hello tokTokTotal Image Limit:[$tokTokImageLimit] Total: ${tokTokTotalImage.length}');
        print('Hello tokTokTotal Video Limit:[$tokTokVideoLimit] Total: ${tokTokTotalVideo.length}');
      }
      await TokTokApi().getUserId(StorageService.getBox.read('DefaultProfile')).then((value) async {
        if (value != null) {
          tokTokObject = value.result;
          tokTokObjectId.value = tokTokObject.objectId.toString();
        }else{
          tokTokObjectId.value = '';
        }
      });
    }
  }
}
