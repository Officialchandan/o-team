import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'Splash.dart';

BaseOptions baseOptions = BaseOptions(headers: {
  'Content-Type': 'application/json',
  'User-Agent': 'Mozilla/5.0 ( compatible )',
  'Accept': '*/*',
}, connectTimeout: 60000, receiveTimeout: 60000);

Dio dio = Dio(baseOptions);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  dio.interceptors.add(LogInterceptor(
      responseBody: true,
      error: true,
      logPrint: (msg) {
        log(msg);
      },
      request: true,
      requestBody: true,
      requestHeader: true,
      responseHeader: true));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'O-team',
      theme: ThemeData(
        fontFamily: "Poppins-SemiBold",
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      builder: EasyLoading.init(),
      // home: DemoTest(),
      /* home: Provider(
        child: MaterialApp(
          title: "Login form using Bloc",
          home: Scaffold(
            appBar: AppBar(
              title: Text('Bloc login form'),
            ),
            body: LoginScreen(),
          ),
        ),
      ),*/
      // home: SwipeFeedPage(),
      // home: GalleryActivity("https://ondshare.nsbbpo.in/Odattandence/20210112/_1610456241229.jpg,https://ondshare.nsbbpo.in/Odattandence/20210112/_1610456254303.jpg"),
      // home: SignInForm(),
      // home: StoreAuditActivity(),
    );
  }
}
