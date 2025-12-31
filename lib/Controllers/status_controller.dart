import 'package:eypop/back4appservice/user_provider/users/provider_profileuser_api.dart';
import 'package:eypop/back4appservice/user_provider/users/provider_user_api.dart';
import 'package:eypop/models/user_login/user_login.dart';
import 'package:eypop/models/user_login/user_profile.dart';
import 'package:eypop/service/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';


class StatusController extends GetxController {

  /// User_Login : AutoDisconnectionChats & NoChats, AutoDisconnectionCalls & NoCalls, AutoDisconnectionVideoCalls & NoVideocalls
  /// User_Profile : AutoDisconnectionChats & NoChats, AutoDisconnectionCalls & NoCalls, AutoDisconnectionVideoCalls & NoVideocalls
  /// when all this 6 column are Null or True then Update the False (True means Disconnect & False means Connect)

  Future loginStatus() async {
    if (StorageService.getBox.read('ObjectId') != null) {
      print('start user_login id ******** ${StorageService.getBox.read('ObjectId')}');
      await UserLoginProviderApi().getById(StorageService.getBox.read('ObjectId')).then((value) async {
        if (value.result != null) {

          if (kDebugMode) {
            print('**** User_Login objectId : ${value.result['objectId']} --- Email : ${value.result['Email']}');
            print('AutoDisconnectionChats : ${value.result['AutoDisconnectionChats']} --- NoChats : ${value.result['NoChats']}');
            print('AutoDisconnectionCalls : ${value.result['AutoDisconnectionCalls']} --- NoCalls : ${value.result['NoCalls']}');
            print('AutoDisconnectionVideoCalls : ${value.result['AutoDisconnectionVideoCalls']} --- NoVideocalls : ${value.result['NoVideocalls']}');
          }

          final UserLogin userLogin = UserLogin();

          /// AutoDisconnectionChats & NoChats
          if (value.result['AutoDisconnectionChats'] ?? true == true && value.result['NoChats'] ?? true == true) {
            userLogin.objectId = value.result['objectId'];
            userLogin.noChats = false;
            userLogin.autoDisconnectionChats = false;
            await UserLoginProviderApi().update(userLogin);
            print('**** Hello result login success chats ****');
          }

          /// AutoDisconnectionCalls & NoCalls
          if (value.result['AutoDisconnectionCalls'] ?? true == true && value.result['NoCalls'] ?? true == true) {
            userLogin.objectId = value.result['objectId'];
            userLogin.noCalls = false;
            userLogin.autoDisconnectionCalls = false;
            await UserLoginProviderApi().update(userLogin);
            print('**** Hello result login success calls ****');
          }

          /// AutoDisconnectionVideoCalls & NoVideocalls
          if (value.result['AutoDisconnectionVideoCalls'] ?? true == true && value.result['NoVideocalls'] ?? true == true) {
            userLogin.objectId = value.result['objectId'];
            userLogin.noVideocalls = false;
            userLogin.autoDisconnectionVideoCalls = false;
            await UserLoginProviderApi().update(userLogin);
            print('**** Hello result login success videocalls ****');
          }
        }
      });
    }
  }

  Future profileStatus() async {
    if (StorageService.getBox.read('ObjectId') != null) {
      await UserProfileProviderApi().getByUserId(StorageService.getBox.read('ObjectId')).then((value) async {
        if (value.results != null) {
          final ProfilePage userProfile = ProfilePage();
          for (var e in value.results!) {

            if (kDebugMode) {
              print('**** Hello result profile **** \nobjectId : ${e['objectId']} --- Name : ${e['Name']}');
              print('AutoDisconnectionChats : ${e['AutoDisconnectionChats']} --- NoChats : ${e['NoChats']}');
              print('AutoDisconnectionCalls : ${e['AutoDisconnectionCalls']} --- NoCalls : ${e['NoCalls']}');
              print('AutoDisconnectionVideoCalls : ${e['AutoDisconnectionVideoCalls']} --- NoVideocalls : ${e['NoVideocalls']}');
            }

            /// AutoDisconnectionChats & NoChats
            if (e['AutoDisconnectionChats'] ?? true == true && e['NoChats'] ?? true == true) {
              userProfile.objectId = e['objectId'];
              userProfile.noChats = false;
              userProfile.autoDisconnectionChats = false;
              await UserProfileProviderApi().update(userProfile);
              print('**** Hello result profile success chats ****');
            }

            /// AutoDisconnectionCalls & NoCalls
            if (e['AutoDisconnectionCalls'] ?? true == true && e['NoCalls'] ?? true == true) {
              userProfile.objectId = e['objectId'];
              userProfile.noCalls = false;
              userProfile.autoDisconnectionCalls = false;
              await UserProfileProviderApi().update(userProfile);
              print('**** Hello result profile success calls ****');
            }

            /// AutoDisconnectionVideoCalls & NoVideocalls
            if (e['AutoDisconnectionVideoCalls'] ?? true == true && e['NoVideocalls'] ?? true == true) {
              userProfile.objectId = e['objectId'];
              userProfile.noVideocalls = false;
              userProfile.autoDisconnectionVideoCalls = false;
              await UserProfileProviderApi().update(userProfile);
              print('**** Hello result profile success videocalls ****');
            }
          }
        }
      });
    }
  }

  @override
  Future<void> onInit() async {
    // await loginStatus();
    // await profileStatus();
    super.onInit();
  }
}
