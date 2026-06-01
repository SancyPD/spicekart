import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final String appId = "353a04ad-9001-4374-8abc-ed855416452a";

  @override
  void onInit() {
    super.onInit();
    initOneSignal();
  }

  void initOneSignal() {
    // Debugging
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialization
    OneSignal.initialize(appId);

    // Permissions
    OneSignal.Notifications.requestPermission(true);

    // Click listener
    OneSignal.Notifications.addClickListener((event) {
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
    });

    // Foreground notification listener
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      
      /// Displays Notification, any custom logic can be added here
      event.notification.display();
    });
  }

  void login(String userId) {
    print('OneSignal Login: $userId');
    OneSignal.login(userId);
  }

  void logout() {
    print('OneSignal Logout');
    OneSignal.logout();
  }
}
