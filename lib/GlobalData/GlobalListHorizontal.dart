import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';

class GlobalHorizontal
{

  static double getRowWidth=150.0;

  static double getRowHeight=48.0;

  static num SubColumnWidth=10;

  static Widget buildSideBox(index,String title, isTitle) {
    return SizedBox(
        height: GlobalHorizontal.getRowHeight,
        width: GlobalHorizontal.getRowWidth,
        child: Container(

            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: index==-1?colorPrimary:Colors.white,
                border: Border(
                    bottom: BorderSide(width: 0.33, color:Colors.black12))),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: isTitle ? 14 : 12,  color: index==-1?Colors.white:Colors.black,),
            )));
  }

  static Widget buildSideBoxHead(index,String title, isTitle) {
    return Container(

        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: index==-1?colorPrimary:Colors.white,
            border: Border(
                bottom: BorderSide(width: 0.1, color:Colors.black12))),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isTitle ? 14 : 12,  color: index==-1?Colors.white:Colors.black,),
        ));
  }
}