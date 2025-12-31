import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:eypop/Constant/constant.dart';
import 'package:eypop/Controllers/call_controller/call_controller.dart';
import 'package:eypop/Controllers/user_controller.dart';
import 'package:eypop/service/calling.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

final RxInt remoteUidVideo = 0.obs;
final RxBool onUserJoin = false.obs;

class AgoraVideoCallController extends GetxController {
  RtcEngine? rtcEngine;
  final CallController callController = Get.put(CallController());

  void agoraInitialize({required String callId, required int uid, required bool isVoiceCall}) async {
    try {
      if (agoraAppId.isEmpty) {
        return;
      }
      if (bgAgoraEngine != null) {
        rtcEngine = bgAgoraEngine!;
        // WHEN VOICE CALL
        if (uid == 2 && isVoiceCall) {
          await recordAgoraCall(callId: callId);
        }
        if (uid == 2 && !isVoiceCall){
          await recordAgoraCall(callId: callId);
        }
        return;
      }
      callController.permissionMic();
      // WHEN VIDEO CALL
      if (!isVoiceCall) {
        callController.permissionCamera();
      }
      await initAgoraRtcEngine();
      addAgoraEventHandlers(isVoiceCall: isVoiceCall);
      // WHEN VIDEO CALL
      if (!isVoiceCall) {
        await rtcEngine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await rtcEngine!.enableVideo();
        await rtcEngine!.startPreview();
      }
      await rtcEngine!.joinChannel(token: agoraAppId, channelId: callId, uid: uid, options: const ChannelMediaOptions(clientRoleType: ClientRoleType.clientRoleBroadcaster));
      // WHEN VOICE CALL
      if (uid == 2 && isVoiceCall) {
        await recordAgoraCall(callId: callId);
      }
      if (uid == 2 && !isVoiceCall){
        await recordAgoraCall(callId: callId);
      }
    } on AgoraRtcException catch (e) {
      print("HELLO AGORA CALL ERROR ${e.code} ${e.message}");
    }
  }

  void onSwitchCamera() {
    if (rtcEngine != null) {
      rtcEngine!.switchCamera();
    }
  }

  Future<void> agoraLeave() async {
    if (rtcEngine != null) {
      rtcEngine!.leaveChannel();
      rtcEngine!.release();
    }
  }

  /// AGORA CALL RECORD API
  Future<void> recordAgoraCall({required String callId}) async {
    final response = await http.get(Uri.parse("$vozipRecordApi?op=record_channel&channel_id=$callId&call_id=${parseCall.value['objectId']}"));
    print('HELLO AGORA VIDEO CALL RECORD API ${response.statusCode} --BODY-- ${response.body}');
  }

  Future<void> initAgoraRtcEngine() async {
    rtcEngine = createAgoraRtcEngine();
    await rtcEngine!.initialize(const RtcEngineContext(appId: agoraAppId, channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
  }

  void addAgoraEventHandlers({required bool isVoiceCall}) {
    rtcEngine!.registerEventHandler(RtcEngineEventHandler(onError: (ErrorCodeType errorCodeType, String message) {
      print('HELLO AGORA CALL ON-ERROR  $message');
    }, onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
      onUserJoin.value = true;
      print('HELLO AGORA CALL ON-JOIN-SUCCESS');
    }, onLeaveChannel: (RtcConnection connection, RtcStats stats) {
      onUserJoin.value = false;
      remoteUidVideo.value = 0;
      print('HELLO AGORA CALL ON-LEAVE-CHANNEL');
    }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
      remoteUidVideo.value = remoteUid;
      print('HELLO AGORA CALL ON-USER-JOIN $remoteUid');
      if (!isVoiceCall) {
        await rtcEngine!.setEnableSpeakerphone(true);
      } else {
        await rtcEngine!.setEnableSpeakerphone(false);
      }
    }, onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
      print('HELLO AGORA CALL ON-USER-OFFLINE');
      rtcEngine!.leaveChannel();
      rtcEngine!.release();
      Get.back();
    }, onFirstRemoteVideoFrame: (RtcConnection connection, int remoteUid, int width, int height, int elapsed) {
      print('HELLO AGORA CALL ON-FIRST-REMOTE-VIDEO-FRAME');
    }));
  }
}
