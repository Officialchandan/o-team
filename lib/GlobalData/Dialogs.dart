import 'dart:io';

import 'package:custom_progress_dialog/custom_progress_dialog.dart';
import 'package:flutter/material.dart';
//import 'package:progress_dialog/progress_dialog.dart';

class Dialogs {
  static ProgressDialog pd;

  static void ackAlert(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                /*  Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.pushNamed(context, Constants.OTPSCREEN);*/
              },
            ),
          ],
        );
      },
    );
  }

  static void showProgressDialog(BuildContext context) {
    if (pd == null) {
      pd = ProgressDialog();
    }
    pd.showProgressDialog(context, textToBeDisplayed: "Loading...", dismissAfter: Duration(minutes: 5));
  }

  static void hideProgressDialog(BuildContext context) {
    if (pd != null) {
      pd.dismissProgressDialog(context);
    }
  }

  static Widget buildProgressIndicator(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  static Future<bool> exitApp(BuildContext context) {
    return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text('Do you want to exit this application?'),
              content: new Text('Press Yes to leave...'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('No'),
                ),
                new FlatButton(
                  onPressed: () => exit(0),
                  child: new Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

abstract class ClickInterface {
  void onClick();
}
