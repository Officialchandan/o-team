import 'dart:convert';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ondoprationapp/DashBoard/DashBoard.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/ReviewAudit/GalleryPhotoClass.dart';

import 'model/SubReviewModel.dart';

class DetailEntryActivity extends StatefulWidget {
  final auditId;
  final mapdata;

  DetailEntryActivity(this.auditId, this.mapdata);

  @override
  State<StatefulWidget> createState() {
    return DetailEntryView();
  }
}

class DetailEntryView extends State<DetailEntryActivity> {
  var TAG = "DetailEntryView";
  String userID = "";
  List<ReviewData> reviewDataList = List();
  TextEditingController controller = new TextEditingController();
  int selectedSubindex = 0;
  int selectedindex = 0;

  @override
  void initState() {
    super.initState();
    UpdateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalWidget.getAppbar("Detail Entry"),
      body: reviewDataList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: <Widget>[
                getWidget(),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: RaisedButton(
                      shape: GlobalWidget.getButtonTheme(),
                      color: GlobalWidget.getBtncolor(),
                      textColor: GlobalWidget.getBtnTextColor(),
                      onPressed: () {
                        if (widget.mapdata == null) {
                          saveFormData();
                        } else {
                          showSubmitDialog(context);
                        }
                      },
                      child: Text(
                        'Submit',
                        style: GlobalWidget.textbtnstyle(),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget getWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 40),
      child: ListView.builder(
        itemCount: reviewDataList.length,
        // shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  alignment: Alignment.center,
                  color: colorPrimary,
                  child: Text(
                    reviewDataList[index].reviewType,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                Column(
                  children: List.generate(
                      reviewDataList[index].review.length,
                      (subIndex) => Container(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4.0, top: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 7,
                                        child: Text(
                                          reviewDataList[index]
                                              .review[subIndex]
                                              .paramName,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: InkWell(
                                          onTap: () {
                                            Utility.log(TAG, widget.mapdata);
                                            if (widget.mapdata != null) {
                                              selectedSubindex = subIndex;
                                              selectedindex = index;
                                              showRatingDialog(
                                                  context,
                                                  reviewDataList[index]
                                                      .review[subIndex]
                                                      .subPoint);
                                            }
                                            //     showRatingDialog(context, reviewDataList[index].review[subIndex].subPoint);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  reviewDataList[index]
                                                                  .review[
                                                                      subIndex]
                                                                  .grade ==
                                                              null ||
                                                          reviewDataList[index]
                                                                  .review[
                                                                      subIndex]
                                                                  .grade ==
                                                              ""
                                                      ? "Select Type"
                                                      : reviewDataList[index]
                                                          .review[subIndex]
                                                          .grade,
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.black,
                                                size: 15,
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4.0, right: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                          flex: 8,
                                          child: InkWell(
                                            onTap: () {
                                              selectedSubindex = subIndex;
                                              selectedindex = index;
                                              showMyDialog(context);
                                            },
                                            child: reviewDataList[index]
                                                        .review[subIndex]
                                                        .new_remark
                                                        .toString() ==
                                                    ""
                                                ? Text("Enter Remark...",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey))
                                                : Text(
                                                    reviewDataList[index]
                                                        .review[subIndex]
                                                        .new_remark
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: colorPrimary)),
                                          )),
                                      Expanded(
                                        flex: 2,
                                        child: reviewDataList[index]
                                                    .review[subIndex]
                                                    .grade !=
                                                null
                                            ? Container(
                                                /* color: reviewDataList[index]
                                                          .review[subIndex]
                                                          .grade ==
                                                      null ||
                                                  reviewDataList[index]
                                                          .review[subIndex]
                                                          .grade ==
                                                      ""
                                              ? Colors.white
                                              : reviewDataList[index]
                                                          .review[subIndex]
                                                          .grade ==
                                                      "Good"
                                                  ? Colors.white
                                                  : reviewDataList[index]
                                                              .review[subIndex]
                                                              .grade ==
                                                          "Excellent"
                                                      ? greenColor
                                                      : reviewDataList[index]
                                                                  .review[
                                                                      subIndex]
                                                                  .grade ==
                                                              "Average"
                                                          ? avgColor
                                                          : reviewDataList[
                                                                          index]
                                                                      .review[
                                                                          subIndex]
                                                                      .grade ==
                                                                  "Poor"
                                                              ? colorPrimary
                                                              : Colors.white,*/
                                                color: getColor(
                                                    reviewDataList[index]
                                                        .review[subIndex]
                                                        .grade),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      reviewDataList[index]
                                                                  .review[
                                                                      subIndex]
                                                                  .score ==
                                                              null
                                                          ? "0.00"
                                                          : reviewDataList[
                                                                  index]
                                                              .review[subIndex]
                                                              .score,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black)),
                                                ),
                                              )
                                            : new Container(),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0, right: 4.0, bottom: 4),
                                    child: Text(
                                      reviewDataList[index]
                                                  .review[subIndex]
                                                  .scoreRem ==
                                              null
                                          ? "Remark : "
                                          : "Remark :" +
                                              reviewDataList[index]
                                                  .review[subIndex]
                                                  .scoreRem,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                reviewDataList[index]
                                                .review[subIndex]
                                                .needImg ==
                                            null ||
                                        reviewDataList[index]
                                                .review[subIndex]
                                                .needImg ==
                                            "0"
                                    ? Container()
                                    : Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              widget.mapdata == null
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        Utility.log(
                                                            TAG,
                                                            reviewDataList[
                                                                    index]
                                                                .review[
                                                                    subIndex]
                                                                .imagePath);
                                                        if (reviewDataList[
                                                                    index]
                                                                .review[
                                                                    subIndex]
                                                                .imagePath ==
                                                            "") {
                                                          GlobalWidget.showToast(
                                                              context,
                                                              "No Images Found.");
                                                        } else {
                                                          Navigator.of(context).push(MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  GalleryActivity(reviewDataList[
                                                                          index]
                                                                      .review[
                                                                          subIndex]
                                                                      .imagePath)));
                                                        }
                                                      },
                                                      child: Container(
                                                        color: colorPrimary,
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Text(
                                                                "View Clicked Image",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : new Container(),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  selectedSubindex = subIndex;
                                                  selectedindex = index;
                                                  bool data =
                                                      await GlobalPermission
                                                          .checkPermissionsCamera(
                                                              context);
                                                  if (data == true) {
                                                    LoadImageFromGallery();
                                                  }
                                                },
                                                child: Container(
                                                  color: colorPrimary,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text("Click Image",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                              ],
                            ),
                          )),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  var _image;
  String path = "";

  Future LoadImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
      path = image.path;
      _asyncFileUpload();
    });
  }

  Future<void> showMyDialog(BuildContext context) async {
    TextEditingController CustomerController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //  title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                new Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 40,
                    ),
                  ),
                ),
                new Container(
                  padding: EdgeInsets.all(10.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Enter Remark",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                new Container(
                  padding: EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    //textInputAction: TextInputAction.done,
                    maxLines: 5,
                    minLines: 2,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    controller: CustomerController,
                    //decoration: GlobalWidget.TextFeildDecoration2("Remark","Enter Remark"),
                    decoration: new InputDecoration(
                      labelText: "Enter Remark",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(2.0),
                        borderSide: new BorderSide(),
                      ),
                      //fillColor: Colors.green
                    ),

                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter Customer ';
                      }
                      return null;
                    },
                  ),
                ),
                new Container(
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    shape: GlobalWidget.getButtonTheme(),
                    color: GlobalWidget.getBtncolor(),
                    textColor: GlobalWidget.getBtnTextColor(),
                    onPressed: () {
                      if (CustomerController.text.toString().length < 0) {
                        GlobalWidget.showToast(context, "Please enter remark");
                      } else {
                        reviewDataList[selectedindex]
                            .review[selectedSubindex]
                            .new_remark = CustomerController.text.toString();
                        Navigator.of(context).pop();
                        setState(() {});
                      }
                      // Validate returns true if the form is valid, otherwise false.
                      /*  if (_formKey.currentState.validate())
                      {
                        getShareddata();
                      }*/
                    },
                    child: Text(
                      'Submit',
                      style: GlobalWidget.textbtnstyle(),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showRatingDialog(BuildContext context, String Rating) async {
    List imageList = new List();
    final tagName = Rating;
    final split = tagName.split(',');
    for (int i = 0; i < split.length; i++) {
      imageList.add(split[i]);
    }
    setState(() {});

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //  title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                new Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 8,
                      child: new Container(
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Select Type".toUpperCase(),
                          style: TextStyle(fontSize: 20, color: colorPrimary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: new Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.cancel,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                new Container(
                  padding: EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  height: imageList.length * 60.0,
                  width: MediaQuery.of(context).size.width,
                  child: new ListView.builder(
                      itemCount: imageList.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, position) {
                        return InkWell(
                          onTap: () {
                            Utility.log(TAG, imageList[position]);
                            reviewDataList[selectedindex]
                                .review[selectedSubindex]
                                .grade = imageList[position];

                            Utility.log(
                                TAG,
                                reviewDataList[selectedindex]
                                    .review[selectedSubindex]
                                    .maxScore);
                            double scoreval = double.parse(
                                reviewDataList[selectedindex]
                                    .review[selectedSubindex]
                                    .maxScore);

                            switch (position) {
                              case 0:
                                scoreval = scoreval * 1;

                                break;

                              case 1:
                                scoreval = scoreval * 0.9;

                                break;

                              case 2:
                                scoreval = scoreval * 0.7;

                                break;

                              case 3:
                                scoreval = scoreval * 0.3;
                                break;

                              default:
                                scoreval = 0.00;

                                break;
                            }

                            Utility.log(TAG, scoreval);
                            scoreval = GlobalConstant.ConvertDecimal1(scoreval);
                            Navigator.of(context).pop();
                            Utility.log(TAG, scoreval);
                            reviewDataList[selectedindex]
                                .review[selectedSubindex]
                                .score = scoreval.toString();
                            setState(() {});
                            /*  SelectedImage =  imageList[position];
                            setState(() {

                            });*/
                          },
                          child: new Column(
                            children: [
                              Divider(
                                thickness: 2.0,
                              ),
                              new Container(
                                  margin: EdgeInsets.all(10.0),
                                  // color: Colors.blue[100],
                                  child: Text(
                                    imageList[position],
                                    style: TextStyle(color: Colors.black),
                                  )),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _asyncFileUpload() async {
    Dialogs.showProgressDialog(context);

    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID =
        (await Utility.getStringPreference(GlobalConstant.USER_ID));
    //create multipart request for POST or PATCH method
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'charset': 'UTF-8',
    };

    var request = http.MultipartRequest(
        "POST", Uri.parse(GlobalConstant.BASE_URL + "data/scrAudImg"));
    request.headers.addAll(requestHeaders);
    //add text fields
    request.fields["audid"] = "${widget.auditId}";
    request.fields["seqNo"] = "${DateTime.now().millisecondsSinceEpoch}";
    request.fields["userId"] = "${USER_ID}";
    request.fields["key"] = "${GlobalConstant.key}";
    request.fields["psw"] = "${userPass}";
    if ("${_image.toString()}" != "null") {
      var gumastaupload =
          await http.MultipartFile.fromPath("fileUpload", _image.path);
      request.files.add(gumastaupload);
    }
    print(request.files);
    print(request.toString());
    var response = await request.send();
    var responseData = await response.stream.toBytes();
    Dialogs.hideProgressDialog(context);

    var responseString = String.fromCharCodes(responseData);
    //GlobalFile.Showsnackbar(_globalKey, "Document Uploaded");
    print(responseString);
    var dataval = json.decode(responseString);

    print(dataval["data"]);
    if (dataval["status"] == 0) {
      String path = dataval["data"];
      String previmag =
          reviewDataList[selectedindex].review[selectedSubindex].imagePath;
      Utility.log(TAG + "old", previmag);

      if (previmag.length == 0) {
      } else if (previmag == null) {
      } else {
        previmag = previmag + ",";
      }
      reviewDataList[selectedindex].review[selectedSubindex].imagePath =
          previmag + path;
      Utility.log(TAG + "new",
          reviewDataList[selectedindex].review[selectedSubindex].imagePath);

      setState(() {});
    }
    /*
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommonMenuDashBoard("shop","home1"),
      ),
    );
*/
  }

  Future<void> showSubmitDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Are you sure you want to save audit?"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.of(context).pop();
                SaveData();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> UpdateData() async {
    var data = GlobalConstant.GetMapForAuditId(widget.auditId);
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Scr_GetParams,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };

    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      // Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(map2()));

        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          if (data1['ds']['tables'].length > 0) {
            var products = data1['ds']['tables'][0]['rowsList'];
            Utility.log(TAG, data.body);

            var list = products;
            var group = groupBy(list, (obj) => obj['cols']['Grp']);

            group.forEach((key, value) {
              List<Review> reviewList = List();

              value.forEach((rev) {
                Review review = Review(
                    empName: rev["cols"]["EmpName"],
                    grade: rev["cols"]["Grade"],
                    grp: rev["cols"]["Grp"],
                    imagePath: rev["cols"]["Imagepath"],
                    maxScore: rev["cols"]["MaxScore"],
                    needImg: rev["cols"]["NeedImg"],
                    paramId: rev["cols"]["ParamId"],
                    paramName: rev["cols"]["ParamName"],
                    score: rev["cols"]["Score"],
                    scoreRem: rev["cols"]["ScoreRem"],
                    subPoint: rev["cols"]["SubPoints"],
                    new_remark: "");
                reviewList.add(review);
              });

              reviewDataList
                  .add(ReviewData(reviewType: key, review: reviewList));
            });

            setState(() {});
          }
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error",
                "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            GlobalWidget.showMyDialog(
                context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        // Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(
            context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  saveFormData() async {
    var data = GetMapForSrc_RvSave(widget.auditId);
    Utility.log(TAG, json.encode(data));
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Scr_RvSave,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(map2()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          GlobalWidget.showToast(context, "Record saved successfully");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
            ModalRoute.withName('/'),
          );
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error",
                "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            GlobalWidget.showMyDialog(
                context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(
            context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  GetMapForSrc_RvSave(auditId) {
    List a1 = new List();
    Map<String, dynamic> map1() => {
          'pname': 'AudId',
          'value': auditId,
        };

    var dmap1 = map1();
    Map<String, dynamic> mapobj1() => {
          'cols': dmap1,
        };

    a1.add(mapobj1());

    Map<String, dynamic> map2() => {
          'pname': 'RvScrXml',
          'value': "<DocumentElement>" + getSrcXml() + "</DocumentElement>",
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };

    a1.add(mapobj2());

    Map<String, dynamic> map3() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };

    return map3();
  }

  String getSrcXml() {
    // StringBuffer src = new StringBuffer();
    var src = "";
    for (int i = 0; i < reviewDataList.length; i++) {
      for (int j = 0; j < reviewDataList[i].review.length; j++) {
        // String Grade = reviewDataList.get(i).getData().get(j).getPercentageType().equalsIgnoreCase("Select Type") ? "" : listItemsData.get(i).getData().get(j).getPercentageType();

        String Grade = reviewDataList[i].review[j].grade == null
            ? ""
            : reviewDataList[i].review[j].grade;
        String Score = reviewDataList[i].review[j].score == null
            ? "0.00"
            : reviewDataList[i].review[j].score.toString();

        String IamgePath = reviewDataList[i].review[j].imagePath;

        IamgePath =
            IamgePath.replaceAll("odnas.jkwh.com", "ondshare.nsbbpo.in");
        Utility.log("IamgePath",
            i.toString() + "  " + j.toString() + "  " + IamgePath.toString());
        src = src +
            "<DT>" +
            "<ParamId>" +
            reviewDataList[i].review[j].paramId +
            "</ParamId>" +
            "<Grade>" +
            Grade.toString() +
            "</Grade>" +
            "<img>" +
            IamgePath +
            "</img>" +
            "<Score>" +
            Score.toString() +
            "</Score>" +
            "<Remark>" +
            reviewDataList[i].review[j].new_remark +
            "</Remark>" +
            "  </DT>";
      }
    }

    return src.toString();
  }

  String getimageXml(String imagePath) {
    return imagePath;
  }

  getColor(String grade) {
    if (grade.toLowerCase().contains("excelle")) {
      return greenColor;
    } else if (grade.toLowerCase().contains("good")) {
      return Colors.blue;
    } else if (grade.toLowerCase().contains("aver")) {
      return Colors.yellow;
    } else if (grade.toLowerCase().contains("poor")) {
      return colorPrimary;
    }
  }

  Future<void> SaveData() async {
    var data = widget.mapdata;
    Utility.log(TAG, data["audid"].toString());
    String auditId = data["audid"].toString();
    List a1 = new List();

    if (auditId != "0") {
      Map<String, dynamic> map1() => {
            'pname': 'AudId',
            'value': auditId,
          };

      var dmap1 = map1();
      Map<String, dynamic> mapobj1() => {
            'cols': dmap1,
          };

      a1.add(mapobj1());
    }

    Map<String, dynamic> map2() => {
          'pname': 'AudBy',
          'value': data["AudBy"].toString(),
        };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
          'cols': dmap2,
        };
    a1.add(mapobj2());

    Map<String, dynamic> map3() => {
          'pname': 'CocoPID',
          'value': data["CocoPID"].toString(),
        };

    var dmap3 = map3();
    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };

    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'Coco',
          'value': data["Coco"].toString(),
        };

    var dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };

    a1.add(mapobj4());

    Map<String, dynamic> map5() => {
          'pname': 'AudType',
          'value': data["AudType"].toString(),
        };

    var dmap5 = map5();
    Map<String, dynamic> mapobj5() => {
          'cols': dmap5,
        };

    a1.add(mapobj5());

    Map<String, dynamic> map6() => {
          'pname': 'Manager',
          'value': data["Manager"].toString(),
        };

    var dmap6 = map6();
    Map<String, dynamic> mapobj6() => {
          'cols': dmap6,
        };

    a1.add(mapobj6());

    Map<String, dynamic> map7() => {
          'pname': 'EmpCount',
          'value': data["EmpCount"].toString(),
        };

    var dmap7 = map7();
    Map<String, dynamic> mapobj7() => {
          'cols': dmap7,
        };

    a1.add(mapobj7());

    Map<String, dynamic> map8() => {
          'pname': 'CustCount',
          'value': data["CustCount"].toString(),
        };

    var dmap8 = map8();
    Map<String, dynamic> mapobj8() => {
          'cols': dmap8,
        };

    a1.add(mapobj8());

    Map<String, dynamic> map9() => {
          'pname': 'Remark',
          'value': data["Remark"].toString(),
        };

    var dmap9 = map9();
    Map<String, dynamic> mapobj9() => {
          'cols': dmap9,
        };

    a1.add(mapobj9());

    Map<String, dynamic> map10() => {
          'pname': 'ScrXML',
          'value': "<DocumentElement>" + getSrcXml() + "</DocumentElement>",
        };

    var dmap10 = map10();
    Map<String, dynamic> mapobj10() => {
          'cols': dmap10,
        };

    a1.add(mapobj10());
/*
    Map<String, dynamic> map2() => {
      'pname': 'RvScrXml',
      'value': "<DocumentElement>" + getSrcXml() + "</DocumentElement>",
    };

    var dmap2 = map2();
    Map<String, dynamic> mapobj2() => {
      'cols': dmap2,
    };

    a1.add(mapobj2());*/

    Map<String, dynamic> mapfinal() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };
    Utility.log(TAG, json.encode(data));
    String userPass =
        (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    userID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> mapdata() => {
          'dbPassword': userPass,
          'dbUser': userID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.Scr_Save,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': mapfinal(),
        };
    ApiController apiController = new ApiController.internal();
    if (await NetworkCheck.check()) {
      Dialogs.showProgressDialog(context);
      try {
        var data = await apiController.postsNew(
            GlobalConstant.SignUp, json.encode(mapdata()));
        Dialogs.hideProgressDialog(context);
        var data1 = json.decode(data.body);
        if (data1['status'] == 0) {
          GlobalWidget.showToast(context, "Record saved successfully");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Dashboard()),
            ModalRoute.withName('/'),
          );
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error",
                "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            GlobalWidget.showMyDialog(
                context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(
            context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }
}
