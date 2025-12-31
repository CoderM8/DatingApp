import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class TranslateController extends GetxController {
  final RxBool translate = false.obs;
  final RxInt spSize = 20.obs;

  Future<TranslateLan?> translateLang({text, targetLanguage}) async {
    try {
      var response =
          await http.get(Uri.parse('https://translation.googleapis.com/language/translate/v2?target=$targetLanguage&key=AIzaSyATHHJzl0i0bYXMltl1NqSb29unjDixD3M&q=$text'));
      if (response.statusCode == 200) {
        final TranslateLan abc = translateLanFromJson(response.body);
        if (abc.data.translations[0].detectedSourceLanguage == 'es') {
          response = await http.get(Uri.parse('https://translation.googleapis.com/language/translate/v2?target=en&key=AIzaSyATHHJzl0i0bYXMltl1NqSb29unjDixD3M&q=$text'));
          return translateLanFromJson(response.body);
        } else {
          return abc;
        }
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }
}

TranslateLan translateLanFromJson(String str) => TranslateLan.fromJson(json.decode(str));

String translateLanToJson(TranslateLan data) => json.encode(data.toJson());

class TranslateLan {
  TranslateLan({required this.data});

  final Data data;

  factory TranslateLan.fromJson(Map<String, dynamic> json) => TranslateLan(data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"data": data.toJson()};
}

class Data {
  Data({required this.translations});

  final List<Translation> translations;

  factory Data.fromJson(Map<String, dynamic> json) => Data(translations: List<Translation>.from(json["translations"].map((x) => Translation.fromJson(x))));

  Map<String, dynamic> toJson() => {"translations": List<dynamic>.from(translations.map((x) => x.toJson()))};
}

class Translation {
  Translation({required this.translatedText, required this.detectedSourceLanguage});

  final String translatedText;
  final String detectedSourceLanguage;

  factory Translation.fromJson(Map<String, dynamic> json) =>
      Translation(translatedText: parseHtmlString(json["translatedText"]), detectedSourceLanguage: json["detectedSourceLanguage"]);

  Map<String, dynamic> toJson() => {"translatedText": translatedText, "detectedSourceLanguage": detectedSourceLanguage};
}

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body!.text).documentElement!.text;
  return parsedString;
}
