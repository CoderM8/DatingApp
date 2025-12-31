import 'dart:io';
import 'package:eypop/service/local_storage.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:vocsy_esys_flutter_share/vocsy_esys_flutter_share.dart';

class PictureController extends GetxController {
  final TextEditingController spam = TextEditingController();
  final TextEditingController winkMsg = TextEditingController();

  final ScrollController controller = ScrollController(initialScrollOffset: 0.0);
  List<String> winkItems = [];

  final RxInt swiperIndex = 0.obs;
  final RxBool blockUser = true.obs;
  final RxBool loop = false.obs;
  final RxBool visible = false.obs;
  final RxBool winkvisible = false.obs;
  final RxBool messagevisible = false.obs;
  final RxBool chatTranslate = false.obs;

  Future<void> getBasics() async {
    final String local = StorageService.getBox.read('languageCode') ?? Get.deviceLocale!.languageCode;

    final QueryBuilder<ParseObject> winkGet = QueryBuilder<ParseObject>(ParseObject('WinkList'));
    final ParseResponse winkApiResponse = await winkGet.query();
    if (winkApiResponse.results != null) {
      for (final ele in winkApiResponse.results ?? []) {
        winkItems.add(ele[local]);
      }
    }
  }

  static const String prefixLink = 'https://eypop.page.link';

  Future<Uri> createDynamicLink(profileid, senderid, path) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: prefixLink,
      link: Uri.parse("$prefixLink/$path?profileid=$profileid&senderid=$senderid"),
      androidParameters: const AndroidParameters(packageName: 'com.actuajeriko.eypop'),
      iosParameters: const IOSParameters(appStoreId: "1628570550", bundleId: 'com.actuajeriko.eypop'),
    );
    final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.short);

    return dynamicLink.shortUrl;
  }

  Future<void> share(imageUrl, userName, description, profileId, senderId) async {
    try {
      Uint8List? list;
      List request = [];
      if (imageUrl != 'EMPTY') {
        request = await Future.wait([HttpClient().getUrl(Uri.parse(imageUrl)), createDynamicLink(profileId, senderId, 'Profile')]);

        // var request = await HttpClient().getUrl(Uri.parse(imageUrl));
        final HttpClientResponse response = await request[0].close();
        list = await consolidateHttpClientResponseBytes(response);
      }
      await VocsyShare.file('EYPOP', 'eypop.jpg', list!, 'image/jpg', text: '$userName\n$description \n${request[1]}');
    } catch (e) {
      if (kDebugMode) {
        print('Hello e e $e');
      }
    }
  }

  _scrollListener() {}

  @override
  void onInit() async {
    getBasics();
    controller.addListener(_scrollListener);
    super.onInit();
  }
}
