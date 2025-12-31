// ignore_for_file: camel_case_types, must_be_immutable

import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  final RxBool isLoad = false.obs;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            isLoad.value = true;
          },
          onPageStarted: (String url) {
            controller.clearCache();
          },
          onPageFinished: (String url) {
            isLoad.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            isLoad.value = false;
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  late WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoad.value) {
        return Center(key: UniqueKey(), child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown));
      }
      return WebViewWidget(controller: controller, key: UniqueKey());
    });
  }
}

class PaymentVew extends StatefulWidget {
  const PaymentVew({Key? key, required this.title, required this.url}) : super(key: key);
  final String title;
  final String url;

  @override
  State<PaymentVew> createState() => _PaymentVewState();
}

class _PaymentVewState extends State<PaymentVew> {
  late WebViewController controller;
  final RxBool isLoad = false.obs;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(Get.context!).scaffoldBackgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            isLoad.value = true;
          },
          onPageStarted: (String url) {
            controller.clearCache();
          },
          onPageFinished: (String url) {
            isLoad.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            isLoad.value = false;
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
        title: Styles.regular(widget.title, c: ConstColors.closeColor, fs: 31.sp),
      ),
      body: Obx(() {
        if (isLoad.value) {
          return Center(child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown));
        }
        return WebViewWidget(controller: controller);
      }),
    );
  }
}
