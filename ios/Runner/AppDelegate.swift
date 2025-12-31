import UIKit
import Flutter
import Parse
import Firebase
import PushKit
import flutter_callkit_incoming
import flutter_local_notifications


//var demoVariable :NSString = ""

//
//    struct GobalVariable{
//
//
//          var demoVariable :NSString = ""
//
//    }

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
//   open var test2 :NSString = ""
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

      FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
      PluginExample.register(with: registrar(forPlugin: "PluginExample"))
      
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
         GeneratedPluginRegistrant.register(with: registry)
       }

      
      let configuration = ParseClientConfiguration {
              $0.applicationId = "YUwjJIdCFCiE1spXhebX2VmbtF9EJR1NUI7WQZ6k"
              $0.clientKey = "meu6pxIUqhlQ5iLLJuc490kAFI7Uz5ok5gk2qp1c"
              $0.server = "https://parseapi.back4app.com"
          }
      

            Parse.initialize(with: configuration)
                      PFUser.enableAutomaticUser()
                              // Get some analytics
                              if let runCount = PFUser.current()?.value(forKey: "runCount") as? Int {
                                  PFUser.current()?.setValue(runCount + 1, forKey: "runCount")
                              } else {
                                  PFUser.current()?.setValue(1, forKey: "runCount")
                              }
                              PFUser.current()?.setValue(Locale.current.languageCode, forKey: "locale")
                              PFUser.current()?.saveInBackground()

                 UNUserNotificationCenter.current().delegate = self

                 UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
                         (granted, error) in
                         print("IOS Permission granted: \(granted)")
                         guard granted else { return }
                         self.getNotificationSettings()
                     }

      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let batteryChannel = FlutterMethodChannel(name: "Receiver",
                                                                  binaryMessenger: controller.binaryMessenger)
                     batteryChannel.setMethodCallHandler({
                       [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in	
                       // This method is invoked on the UI thread.
                         
                         guard let args = call.arguments as? [String : Any] else {
                             if let installation = PFInstallation.current(){
                                 if call.method == "DeviceMethod" {
                                 var map = [String:Any]()
                                 map["objectId"] = installation.objectId;
                                 map["UserId"] = installation["UserId"];
                                 map["deviceToken"] = installation["deviceToken"];
                                 print("IOS current installation\(map)")

                                 result(map)
                                     
                                 }
                                 
                             }
                             return}
                         let userId = args["UserObjectId"] as! String
                         
                         print("IOS USERID \(userId)")

                         if let installation = PFInstallation.current(){
                             installation.setObject(userId, forKey: "UserId")
                             installation.saveInBackground {
                                 (success: Bool, error: Error?) in
                                 if (success) {
                                  let objectId = installation.objectId as! String
                                    print("IOS installation save success: ObjectId \(objectId)")
                                 } else {
                                     if let myError = error{
                                         print("IOS Error saving parse installation \(myError.localizedDescription)")
                                     }else{
                                         print("IOS Unknown error")
                                     }
                                 }
                             }
                         }

                        
                        
                     })
      
      //Setup VOIP
      let mainQueue = DispatchQueue.main
      let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
      voipRegistry.delegate = self
      voipRegistry.desiredPushTypes = [PKPushType.voIP]
      

           return super.application(application, didFinishLaunchingWithOptions: launchOptions)
         }

    // Call back from Recent history
    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard let handleObj = userActivity.handle else {
            return false
        }
        
        guard let isVideo = userActivity.isVideo else {
            return false
        }
        let objData = handleObj.getDecryptHandle()
        let nameCaller = objData["nameCaller"] as? String ?? ""
        let handle = objData["handle"] as? String ?? ""
        let data = flutter_callkit_incoming.Data(id: UUID().uuidString, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
        //set more data...
        //data.nameCaller = nameCaller
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.startCall(data, fromPushKit: true)
        
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    

    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        let deviceTokenString = credentials.token.reduce("") { $0 + String(format: "%02X", $1) }
        NSLog("IOS Hello deviceTokenString: \(deviceTokenString)")
        print("IOS Hello deviceToken setDevicePushTokenVoIP: \(deviceToken)")
        //Save deviceToken to your server
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("IOS didInvalidatePushTokenFor")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("IOS didReceiveIncomingPushWith \(payload.dictionaryPayload)")
//        guard type == .voIP else { return }
        
        let id = payload.dictionaryPayload["id"] as? String ?? ""
        let nameCaller = payload.dictionaryPayload["nameCaller"] as? String ?? ""
        let handle = payload.dictionaryPayload["handle"] as? String ?? ""
        let isVideo = payload.dictionaryPayload["isVideo"] as? String ?? "false"
        let extra = payload.dictionaryPayload["extra"]  as? [String: Any]

//          let data = extra as? [String: Any]
        
        let userId = extra?["UserId"] as? String ?? ""
        let senderId = extra?["senderId"] as? String ?? ""
        let callId = extra?["callId"] as? String ?? ""
        let type = extra?["type"] as? String ?? ""
            print("IOS extra parameter userId \(userId)")
            print("IOS extra parameter senderId \(senderId)")
            print("IOS extra parameter callId \(callId)")
            print("IOS extra parameter isVideo \(isVideo)")
            print("IOS extra parameter type \(type)")

        
        let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller, handle: handle, type: isVideo == "true" ? 1 : 0)
        //set more data
        data.extra = ["user": "abc@123", "platform": "ios","UserId":userId,"senderId":senderId,"callId":callId]
        //data.iconName = ...
        //data.....
        if(type == "Calling you"){
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)
        }else if (type == "Cut"){
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.endCall(data)
        }
       
        
        //Make sure call completion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion()
        }
    }
    
           override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
                      {
                          let userInfo = notification.request.content.userInfo
                          print("IOS FOREGROUND USER INFO \(userInfo)")
                           /// show notification (when ios app foreground)
                           if let userInfo = userInfo as? [String: Any],
                               let type = userInfo["translatedAlert"] as? String{
                               // Use the translatedAlert value here
                               print("IOS Notification Foreground Type: \(type)")
                               if(type == "Send Notification" || type == "go_internal_link" || type == "go_advertisement"){
                                   if #available(iOS 14.0, *) {
                                      print("Start Send IOS Notification 1 ******")
                                       completionHandler([.banner, .badge, .sound])
                                   } else {
                                      print("Start Send IOS Notification 2 ******")
                                       completionHandler([.alert, .badge, .sound])
                                       // Fallback on earlier versions
                                   }
                               }
                           }
                      }


                var isClear = false // Flag to prevent re-setting the method call handler

                override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                                      didReceive response: UNNotificationResponse,
                                                      withCompletionHandler completionHandler: @escaping () -> Void) {
                    let userInfo = response.notification.request.content.userInfo
                    print("Notification UserInfo Tap Only---------------> \(userInfo)")
                    self.isClear = false

                    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
                    let batteryChannel = FlutterMethodChannel(name: "Receiver", binaryMessenger: controller.binaryMessenger)

                    // Only set the method call handler once (if not already set)
                        batteryChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
                            // Safely unwrap self to access the isBatteryChannelSet flag
                            guard let self = self else { return }

                            guard let args = call.arguments as? [String: Any] else { return }
                            let userId = args["UserObjectId"] as! String

                            print("IOS BACKGROUND USERID \(userId)")

                            if (call.method == "ReceiverMethod" && !isClear) {
                                // Send userInfo back to Flutter
                                result(userInfo as? [String: Any])

                                // Set the flag to true after setting the handler
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                     // Do not reset method call handler here. We are managing it with the flag.
                                     print("*** IOS background delay ***")
                                     self.isClear = true
                                 }

                            }
                        }
                        print("*** IOS background completionHandler ***")
                        completionHandler()
                }


               func getNotificationSettings() {
                   UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                       print("IOS Notification settings: \(settings)")
                       guard settings.authorizationStatus == .authorized else { return }
                       UIApplication.shared.registerForRemoteNotifications()
                   }
               }

               override func application(_ application: UIApplication,
                                didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Foundation.Data) {
                                 Messaging.messaging().apnsToken = deviceToken
                   createInstallationOnParse(deviceTokenData: deviceToken)
               }

               override func application(_ application: UIApplication,
                                didFailToRegisterForRemoteNotificationsWithError error: Error) {
                   print("IOS Failed to register: \(error)")
               }

               func createInstallationOnParse(deviceTokenData:Foundation.Data){
                   if let installation = PFInstallation.current(){
                       installation.setDeviceTokenFrom(deviceTokenData)
//                       installation.setObject("UserId", forKey: "UserId")
                       installation.saveInBackground {
                           (success: Bool, error: Error?) in
                           if (success) {
                               let objectId = installation.objectId as! String
                              print("IOS installation saveInBackground success: ObjectId \(objectId)")
                           } else {
                               if let myError = error{
                                   print("IOS Error saveInBackground parse installation \(myError.localizedDescription)")
                               }else{
                                   print("IOS Unknown saveInBackground error")
                               }
                           }
                       }
                   }
               }

       }
