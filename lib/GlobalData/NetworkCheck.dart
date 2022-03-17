import 'package:connectivity/connectivity.dart';

class NetworkCheck {
  static Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print(ConnectivityResult.mobile);
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print(ConnectivityResult.wifi);
      return true;
    }
    print("connectivityResult-> ${connectivityResult.toString()}");
    return false;
  }

  Future<bool> checks() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        return true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        return true;
      }
      return false;
    } catch (Exception) {
      print("Error in ${Exception.toString()}");
      return false;
    }
  }

  dynamic checkInternet(Function func) {
    checks().then((intenet) {
      if (intenet != null && intenet) {
        func(true);
      } else {
        func(false);
      }
    });
  }
}