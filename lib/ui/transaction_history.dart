import 'package:eypop/Constant/Widgets/button.dart';
import 'package:eypop/Controllers/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../Constant/Widgets/textwidget.dart';
import '../Constant/constant.dart';
import '../Controllers/pdf_view_controller.dart';

class TransactionView extends GetView {
  const TransactionView({Key? key}) : super(key: key);

  static PaymentController get _paymentController => Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
        title: Styles.regular('Payment_history'.tr, c: ConstColors.closeColor, fs: 31.sp),
      ),
      body: FutureBuilder<ParseResponse?>(
          future: _paymentController.getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null && snapshot.data!.results != null) {
                return ListView.separated(
                  padding: EdgeInsets.only(top: 14.h, left: 17.w, right: 17.w),
                  key: UniqueKey(),
                  itemCount: snapshot.data!.results!.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final bool pending = (snapshot.data!.results![index]['Status'] == 'PENDING');
                    final bool success = (snapshot.data!.results![index]['Status'] == 'SUCSESS');
                    return InkWell(
                      onTap: (success && snapshot.data!.results![index]["BillPdf"] != null)
                          ? () {
                              Get.to(() => BillPdfView(
                                  url: snapshot.data!.results![index]["BillPdf"].url,
                                  invoiceNumber: snapshot.data!.results![index]["InvoiceNumber"]));
                            }
                          : null,
                      child: Column(
                        children: [
                          SizedBox(height: 13.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Styles.regular(
                                      pending
                                          ? 'Requested'.tr
                                          : success
                                              ? 'Success'.tr
                                              : 'Refused'.tr,
                                      ff: 'RB',
                                      fs: 18.sp,
                                      c: pending
                                          ? Theme.of(context).primaryColor
                                          : success
                                              ? const Color(0xff12E3A4)
                                              : const Color(0xffFC636B)),
                                  Styles.regular(' - ${DateFormat("dd/MM HH:mm").format(snapshot.data!.results![index]['createdAt'].toLocal())}',
                                      ff: 'RR', fs: 14.sp, c: Theme.of(context).primaryColor)
                                ],
                              ),
                              Styles.regular('${double.parse(snapshot.data!.results![index]['Amount'].toString()).toStringAsFixed(2)} €',
                                  ff: 'RB', fs: 20.sp, c: Theme.of(context).primaryColor, fw: FontWeight.bold)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Styles.regular(
                                    /// withdraw Type show
                                    '${getPaymentTypeLabel('${snapshot.data!.results![index]['Type']}')}  ',
                                    ff: 'RR',
                                    fs: 16.sp,
                                    c: Theme.of(context).primaryColor,
                                  ),
                                  if (snapshot.data!.results![index]['Mail'] != null && snapshot.data!.results![index]['Mail'].toString().isNotEmpty)
                                    Styles.regular(snapshot.data!.results![index]['Mail'], ff: 'RR', fs: 16.sp, c: Theme.of(context).primaryColor)
                                  else
                                    Styles.regular(
                                        snapshot.data!.results![index]['BankDetails'] != null
                                            ? snapshot.data!.results![index]['BankDetails']['AccountNumber']
                                            : '',
                                        ff: 'RR',
                                        fs: 16.sp,
                                        c: Theme.of(context).primaryColor),
                                ],
                              ),
                              Styles.regular('${snapshot.data!.results![index]['Amount'] * 100} ${'Stars'.tr}',
                                  ff: 'RR', fs: 14.sp, c: Theme.of(context).primaryColor)
                            ],
                          ),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  key: UniqueKey(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgView('assets/Icons/transaction.svg', color: ConstColors.closeColor, height: 70.w, width: 70.w, fit: BoxFit.cover),
                      SizedBox(height: 20.h),
                      Styles.regular('no_history_found'.tr, c: Theme.of(context).primaryColor, ff: "HB"),
                    ],
                  ),
                );
              }
            } else {
              return Center(
                  key: UniqueKey(), child: Lottie.asset('assets/jsons/three-dot-loading.json', height: 98.w, width: 98.w, fit: BoxFit.scaleDown));
            }
          }),
    );
  }

  String getPaymentTypeLabel(String type) {
    if (type.contains(PaymentType.WesternUnion.name)) {
      return 'WesternUnion';
    } else if (type.contains(PaymentType.Bizun.name)) {
      return 'Bizun';
    } else if (type.contains(PaymentType.Iban.name)) {
      return 'Iban';
    } else if (type.contains(PaymentType.Swift.name)) {
      return 'Swift';
    } else if (type.contains(PaymentType.Paypal.name)) {
      return '${'paypal'.tr}  ';
    } else if (type.contains('Banco') || type.contains('Bank')) {
      return 'bank'.tr;
    } else {
      return 'bank'.tr;
    }
  }
}

class BillPdfView extends StatelessWidget {
  const BillPdfView({Key? key, required this.invoiceNumber, required this.url}) : super(key: key);
  final String invoiceNumber;
  final String url;

  static PdfViewController get _pdfViewController => Get.put(PdfViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading: Back(svg: 'assets/Icons/close.svg', color: ConstColors.closeColor, height: 28.w, width: 28.w),
        title: Styles.regular('pdf_bill'.tr, c: ConstColors.closeColor, fs: 31.sp),
        actions: [
          IconButton(
            color: ConstColors.themeColor,
            onPressed: () {
              _pdfViewController.share(pdflink: url, invoiceNUmber: invoiceNumber);
            },
            icon: SvgPicture.asset("assets/Icons/pdfshare.svg"),
          )
        ],
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
