import 'dart:core';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Languages extends ParseObject implements ParseCloneable {
  static const String keyLanguages = 'Languages';
  static const String keyTitle = 'title';
  static const String keyImage = 'Image';
  Languages() : super(keyLanguages);

  Languages.clone() : this();

  @override
  Languages clone(Map<String, dynamic> map) => Languages.clone()..fromJson(map);

  String? get title => get<String>(keyTitle);
  set title(String? title) => set<String>(keyTitle, title!);

  ParseFile? get image => get<ParseFile>(keyImage);
  set image(ParseFile? image) => set<ParseFile>(keyImage, image!);
}
