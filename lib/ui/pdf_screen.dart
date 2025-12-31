// ignore_for_file: must_be_immutable

import 'package:eypop/Constant/Widgets/textwidget.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/pdf_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PdfView extends GetView {
  PdfView(
      {Key? key,
      required this.invoiceNumber,
      required this.irpf,
      required this.acompanyname,
      required this.acif,
      required this.aaddress,
      required this.apostalcode,
      required this.acity,
      required this.acountry,
      required this.atax,
      required this.date,
      required this.pdfLink,
      required this.amount})
      : super(key: key);

  String invoiceNumber;
  int irpf;
  String acompanyname;
  String acif;
  String aaddress;
  String apostalcode;
  String acountry;
  String acity;
  String date;
  String pdfLink;
  int amount;
  int atax;

  final PdfViewController _pdfViewController = Get.put(PdfViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        shadowColor: ConstColors.white,
        elevation: 0.3,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: ConstColors.themeColor,
            )),
        title: Styles.regular("Factura", c: ConstColors.themeColor),
        actions: [
          IconButton(
              color: ConstColors.themeColor,
              onPressed: () {
                _pdfViewController.share(pdflink: pdfLink, invoiceNUmber: invoiceNumber);
              },
              icon: SvgPicture.asset("assets/Icons/pdfshare.svg"))
        ],
      ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Obx(() {
                  _pdfViewController.isModified.value;
                  return Padding(
                    padding: EdgeInsets.only(left: 10.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Styles.regular(
                          "${_pdfViewController.name} ${_pdfViewController.surName}",
                          // "111",
                        ),
                        Styles.regular(
                          "${_pdfViewController.taxId}",
                          // "111",
                        ),
                        Styles.regular(
                          "${_pdfViewController.home}",
                          // "",
                        ),
                        Styles.regular(
                          "${_pdfViewController.city} ${_pdfViewController.postalCode}",
                          // "111",
                        ),
                        Styles.regular(
                          "${_pdfViewController.country}",
                          // "111",
                        ),
                        SizedBox(height: 20.h),
                        Styles.regular(
                          acompanyname,
                          // "",
                          ff: "RR",
                          fs: 18.sp,
                          c: Theme.of(context).primaryColor,
                        ),
                        Styles.regular(
                          "CIF: $acif",
                          // "",
                          ff: "RR",
                          fs: 18.sp,
                          c: Theme.of(context).primaryColor,
                        ),
                        Styles.regular(
                          aaddress,
                          // "111",
                          ff: "RR",
                          fs: 18.sp,
                          c: Theme.of(context).primaryColor,
                        ),
                        Styles.regular(
                          "$apostalcode $acity $acountry",
                          // "111",
                          ff: "RR",
                          fs: 18.sp,
                          c: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: 20.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0.w),
                            child: Styles.regular(
                              "$acity a $date",
                              // "111",
                              ff: "RR",
                              fs: 18.sp,
                              c: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0.w),
                            child: Styles.regular(
                              "FACTURA Nº $invoiceNumber",
                              // "",
                              ff: "RB",
                              fs: 18.sp,
                              c: const Color(0xffd31020),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Obx(() {
                  _pdfViewController.isModified.value;
                  return Container(
                    color: ConstColors.grey,
                    margin: EdgeInsets.only(bottom: 10.h, top: 10.h),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.r),
                          child: Row(
                            children: [
                              Styles.regular(
                                "Can.",
                                ff: "RB",
                                fs: 18.sp,
                                c: Theme.of(context).primaryColor,
                              ),
                              SizedBox(width: 20.w),
                              Styles.regular(
                                "Concepto",
                                ff: "RB",
                                fs: 18.sp,
                                c: Theme.of(context).primaryColor,
                              ),
                              const Spacer(),
                              Styles.regular(
                                "Precio",
                                ff: "RB",
                                fs: 18.sp,
                                c: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: EdgeInsets.all(10.r),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Styles.regular(
                                  "1",
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Styles.regular(
                                  "En concepto de regalías, por los \nDerechos de autor de mis obras",
                                  al: TextAlign.start,
                                ),
                              ),
                              Styles.regular("${amount.toStringAsFixed(2)} €", c: Theme.of(context).primaryColor)
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.r, bottom: 10.h, top: 20.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Spacer(flex: 3),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    irpf != 0
                                        ? const SizedBox()
                                        : Styles.regular(
                                            "SUMA",
                                            ff: "RB",
                                            fs: 18.sp,
                                            c: Theme.of(context).primaryColor,
                                          ),
                                    irpf == 0
                                        ? const SizedBox()
                                        : Styles.regular(
                                            "IRPF",
                                            ff: "RB",
                                            fs: 18.sp,
                                            c: Theme.of(context).primaryColor,
                                          ),
                                    Styles.regular(
                                      "IVA 21%",
                                      ff: "RB",
                                      fs: 18.sp,
                                      c: Theme.of(context).primaryColor,
                                    ),
                                    Styles.regular(
                                      "TOTAL :",
                                      ff: "RB",
                                      fs: 18.sp,
                                      c: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Styles.regular(
                                      "${amount.toStringAsFixed(2)} €",
                                    ),
                                    irpf == 0
                                        ? const SizedBox()
                                        : Styles.regular(
                                            "${((amount * irpf) / 100).toStringAsFixed(2)} €",
                                          ),
                                    irpf == 0
                                        ? const SizedBox()
                                        : Styles.regular(
                                            "${(amount - (amount * irpf) / 100).toStringAsFixed(2)} €",
                                            ff: "RB",
                                            fs: 18.sp,
                                            c: Theme.of(context).primaryColor,
                                          ),
                                    Styles.regular("${(amount * 0.21).toStringAsFixed(2)} €", c: Theme.of(context).primaryColor),
                                    Styles.regular(
                                      "${(amount - (amount * irpf) / 100).toStringAsFixed(2)} €",
                                      ff: "RB",
                                      fs: 18.sp,
                                      c: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Obx(() {
                  return Container(
                    padding: EdgeInsets.all(10.r),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Styles.regular(
                          "Forma de pago:",
                          ff: "RB",
                          fs: 18.sp,
                          c: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: 10.h),
                        Styles.regular("${_pdfViewController.bankName}",
                            // "",
                            c: Theme.of(context).primaryColor),
                        Styles.regular("${_pdfViewController.country}",
                            // "",
                            c: Theme.of(context).primaryColor),
                        Styles.regular("${_pdfViewController.accountNumber}",
                            // "",
                            c: Theme.of(context).primaryColor),
                        Styles.regular("${_pdfViewController.code}",
                            // "",
                            c: Theme.of(context).primaryColor),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                }),
              ],
            ),
          )),
    );
  }
}
