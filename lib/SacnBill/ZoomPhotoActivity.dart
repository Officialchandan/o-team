import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:photo_view/photo_view.dart';

class ZoomPhotoActivity extends StatefulWidget {
  final imagePath;
  ZoomPhotoActivity(this.imagePath);

  @override
  State<StatefulWidget> createState() {
    Utility.log("tagimagecome", imagePath);
    return ZoomPhotoView();
  }
}

class ZoomPhotoView extends State<ZoomPhotoActivity> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GlobalWidget.getAppbar("Zoom Image"),
        body: Container(
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: Container(
                  child: PhotoView(
                      imageProvider:
                          widget.imagePath.toString().contains("https://")
                              ? NetworkImage(widget.imagePath)
                              : FileImage(File(widget.imagePath))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
