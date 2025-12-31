import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PornModerationController extends GetxController {
  Future<Map<String, dynamic>> asyncFileUpload({File? file}) async {
    final request = http.MultipartRequest("POST", Uri.parse("https://www.picpurify.com/analyse/1.1"));

    // request.fields["API_KEY"] = "RC2MfsjjGPCjhJ639iqJfKbqW6D6S8lI";

    ///new key
    request.fields["API_KEY"] = "sbpxtuybZGf0luXraPNVhGSsuyruaQyq";
    // request.fields["task"] =
    //     "porn_moderation,gore_moderation,obscene_gesture_moderation,suggestive_nudity_moderation";
    request.fields["task"] = "porn_moderation";
    var pic = await http.MultipartFile.fromPath("file_image", file!.path);

    request.files.add(pic);

    http.Response response = await http.Response.fromStream(await request.send());

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    return jsonResponse;
  }
}
