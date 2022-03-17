import 'package:flutter/cupertino.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class GlobalPermission {

  static Future<bool> checkPermissionsCamera(BuildContext context) async {
    bool result=false;
    Map<Permission, PermissionStatus> permissions = await [
      //Permission.storage,
      Permission.camera,
    ].request();

    if (permissions[Permission.camera] != PermissionStatus.granted ) {
      try
      {
        openAppSettings();
        Toast.show("Please Enable permission", context);
      } on Exception {
        print("Permission Error ===> ");
      }
    } else {
      result=true;
    }
    Utility.log("tag", result);
    return result;
  }


 static Future<bool> checkPermissions(BuildContext context) async {
    bool result =false;
    Map<Permission, PermissionStatus> permissions = await [
      Permission.location,
      Permission.locationAlways,
    ].request();



    if (permissions[Permission.location] == PermissionStatus.granted ||
        permissions[Permission.locationAlways] == PermissionStatus.granted)
    {
     result =true;
    } else
    {
      openAppSettings();
      Toast.show("Please Enable permission", context);

    }
    return result;
  }

}