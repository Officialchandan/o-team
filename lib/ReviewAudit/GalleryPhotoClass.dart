import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:photo_view/photo_view.dart';

class GalleryActivity extends StatefulWidget
{
  String ImagePath;

  GalleryActivity(this.ImagePath);

  @override
  State<StatefulWidget> createState() {
   return GalleryView();
  }
}

class GalleryView extends State<GalleryActivity>
{
  List imageList =new List();
  @override
  void initState() {
    super.initState();
    final tagName =widget.ImagePath;
    final split = tagName.split(',');
    SelectedImage =split[0];
    for (int i = 0; i < split.length; i++)
      {
        imageList.add(split[i]);
        Utility.log("TAG", split[i]);
      }
      setState(() {
      });
  }

  String SelectedImage;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return SafeArea(
     child: new Scaffold(
       appBar: GlobalWidget.getAppbar("Image Gallery"),
       body:  new Container(
         child: new Column(
           children: [
             Expanded(flex: 9,
             child: new Container(
               child: PhotoView(
                 imageProvider:new NetworkImage(
                     SelectedImage,
                     headers: {"Authorization": "Basic c2hhcmV1c2VyOl5INFxOcSgz"}
                 ),
               ),
             ),),
             Expanded(flex: 1,
             child:  new ListView.builder(
                 itemCount: imageList.length,
                 scrollDirection: Axis.horizontal,
                 itemBuilder: (context, position) {
                   return InkWell(
                     onTap: ()
                     {
                       SelectedImage =  imageList[position];
                       setState(() {

                       });
                     },
                     child: new Container(
                         margin: EdgeInsets.all(10.0),
                         color: Colors.blue[100],
                         child: FadeInImage(
                           placeholder: AssetImage("drawable/logo_small.png"),
                           image: NetworkImage(
                               imageList[position],
                               headers: {"Authorization": "Basic c2hhcmV1c2VyOl5INFxOcSgz"}),
                         )

                     ),
                   );
                 }),),
           ],
         ),
       ),
     ),
   );
  }

}