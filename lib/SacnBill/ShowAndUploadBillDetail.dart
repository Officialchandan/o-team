import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ondoprationapp/GlobalData/ApiController.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/Dialogs.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalPermission.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/NetworkCheck.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';
import 'package:ondoprationapp/SacnBill/ZoomPhotoActivity.dart';
import 'package:path/path.dart' as pathas;
import 'package:toast/toast.dart';

import 'ImageModel.dart';

class ShowBillDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  ShowBillDetails({this.data});

  @override
  State<StatefulWidget> createState() {
    return ShowData();
  }
}

class ShowData extends State<ShowBillDetails> {
  TextEditingController _controller = TextEditingController();
  String compressValue = "40";
  bool uploading = false;
  List<ImageModel> imageModelList = [];
  String COCO_NAME = "";
  var _image, compressedImage;
  String path = "";

  @override
  void initState() {
    print("data--${widget.data}");

    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(2.0),
        color: colorPrimary,
        child: Row(
          children: [
            Expanded(
              child: getUpdateBtn(context),
            ),
            Container(
              width: 2.0,
              color: Colors.white,
              height: 40.0,
            ),
            Expanded(
              child: getCloseBtn(context),
            )
          ],
        ),
      ),
      appBar: GlobalWidget.getAppbar("Scan Bill:direct(${COCO_NAME})"),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("Dno: ${widget.data["pgiNo"].toString()}"),
                ),
                Expanded(
                  child: Text(
                    "Sup: ${widget.data["supplier"].toString()}",
                    // style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 3,
            //       child: Text(
            //         "InvNo. " + widget.data["InvoiceNo"].toString(),
            //         style: TextStyle(color: Colors.black),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 7,
            //       child: Text(
            //         "Inv Date : " + widget.data["InvoiceDt"].toString(),
            //         style: TextStyle(color: Colors.grey),
            //         textAlign: TextAlign.end,
            //       ),
            //     )
            //   ],
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 3,
            //       child: Text(
            //         "PO. " + widget.data["PoId"].toString(),
            //         style: TextStyle(color: Colors.blue),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 7,
            //       child: Text(
            //         widget.data["Typ"].toString(),
            //         style: TextStyle(color: Colors.black),
            //         textAlign: TextAlign.end,
            //       ),
            //     )
            //   ],
            // ),
            // Text(widget.data["Supplier"].toString(),
            //     style: TextStyle(color: Colors.red)),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 4,
            //       child: Text(
            //         "Compression " + compressValue + "%",
            //         style: TextStyle(color: Colors.blue, fontSize: 14),
            //       ),
            //     ),
            //     Expanded(
            //       flex: 6,
            //       child: GestureDetector(
            //           onTap: () {
            //             openCompressDialog(context);
            //           },
            //           child: Text(
            //             "Change",
            //             style: TextStyle(color: Colors.blue),
            //             textAlign: TextAlign.end,
            //           )),
            //     )
            //   ],
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            getCameraBtn(),
            SizedBox(
              height: 30,
            ),
            GridView.builder(
              itemCount: imageModelList.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => ZoomPhotoActivity(imageModelList[index].imagePath)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: imageModelList[index].uploadStatus == 1
                                    ? Icon(
                                        Icons.check,
                                        size: 40,
                                        color: greenColor,
                                      )
                                    : Container()),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      imageModelList.removeAt(index);
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.black,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 150,
                          child: Image.file(
                            File(imageModelList[index].imagePath),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  clickImage() async {
    bool permission = await GlobalPermission.checkPermissionsCamera(context);
    if (permission) {
      File image = await ImagePicker.pickImage(
          source: ImageSource.camera /*,maxWidth: 960,maxHeight: 1280,imageQuality: int.parse(compressValue.trim())*/);

      setState(() {
        imageModelList.add(ImageModel(0, image.path));
      });
    }
  }

  Future<bool> uploadImage(String image, int index) async {
    bool upload = false;
    debugPrint("image-->$image");
    String userPass = await Utility.getStringPreference(GlobalConstant.USER_PASSWORD);
    String userId = await Utility.getStringPreference(GlobalConstant.USER_ID);
    String url = GlobalConstant.BASE_URL + "data/savePGIImg2";

    Map<String, dynamic> input = {};
    input["userId"] = "$userId";
    input["psw"] = "$userPass";
    input["did"] = "${widget.data["did"]}";
    input["scanType"] = "${widget.data["scanType"]}";
    input["seqNo"] = "${index + 1}";
    input["key"] = "${GlobalConstant.key}";

    if (image.isNotEmpty) {
      debugPrint("image_path-->$image");
      input["fileUpload"] = MultipartFile.fromFileSync(image, filename: pathas.basename(image));
    }

    Map<String, dynamic> res = await ApiController.getInstance().postMultipart(url: url, input: input);

    if (res['status'].toString() == "0") {
      GlobalWidget.showToast(context, "Success");
      upload = true;
    } else {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      if (res['msg'].toString() == "Login failed for user") {
        GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
      } else {
        GlobalWidget.showMyDialog(context, "Error", res['msg'].toString());
      }
    }

    return upload;
  }

  _asyncFileUpload(String imagePath, int index) async {
    debugPrint("_asyncFileUpload-->$imagePath");

    imagePath = path;
    debugPrint("_asyncFileUpload1-->$imagePath");

    if (uploading) return;
    uploading = true;
    Dialogs.showProgressDialog(context);
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String userId = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    String cocoId = (await Utility.getStringPreference(GlobalConstant.COCO_ID));

    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'charset': 'UTF-8',
    };

    String url = GlobalConstant.BASE_URL + "data/savePGIImg2";

    var request = http.MultipartRequest("POST", Uri.parse(url));
    print("request-->$request");

    request.headers.addAll(requestHeaders);
    print("headers->${request.headers}");

    request.fields["userId"] = "$userId";
    request.fields["psw"] = "$userPass";
    request.fields["did"] = "${widget.data["did"]}";
    request.fields["scanType"] = "${widget.data["scanType"]}";
    //request.fields["seqNo"] = "${widget.data["DocNo"] + pathas.basename(imagePath.toString().replaceAll(".jpg", "").replaceAll(".png", "").replaceAll(".jpeg", ""))}";
    request.fields["seqNo"] = "${index + 1}";
    request.fields["key"] = "${GlobalConstant.key}";
    Utility.log(TAG,
        pathas.basename(pathas.basename(imagePath.toString().replaceAll(".jpg", "").replaceAll(".png", "").replaceAll(".jpeg", ""))));

    Utility.log(TAG, request.toString());
    if ("${imagePath.toString()}" != "null") {
      var gumastaupload = await http.MultipartFile.fromPath("fileUpload", imagePath);
      print("gumastaupload-->$gumastaupload");
      request.files.add(gumastaupload);
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      Utility.log(TAG, responseString);

      var data1 = json.decode(responseString);
      Utility.log(TAG, data1["status"].toString());
      Dialogs.hideProgressDialog(context);
      print("responseString-->$responseString");
      if (data1['status'].toString() == "0") {
        imageModelList[index].uploadStatus = 1;
        setState(() {
          uploading = false;
          GlobalWidget.showToast(context, "Success");
        });
      } else {
        uploading = false;
        if (data1['msg'].toString() == "Login failed for user") {
          GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
        } else {
          GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
        }
      }

      for (int i = index + 1; i < imageModelList.length; i++) {
        if (imageModelList[i].uploadStatus == 0) {
          _asyncFileUpload(imageModelList[i].imagePath, i);
          break;
        }
      }
    } catch (e) {
      uploading = false;
      Dialogs.hideProgressDialog(context);
      GlobalWidget.showMyDialog(context, "", GlobalConstant.interNetException(e.toString()));
    }
  }

  stockIdField() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        // keyboardType: TextInputType.number,
        keyboardType: TextInputType.text,

        //textInputAction: TextInputAction.done,
        maxLength: 3,
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        controller: quantityController,
        decoration: GlobalWidget.TextFeildDecoration1("Compression %"),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter Compression % ';
          }

          return null;
        },
      ),
    );
  }

  Future<void> submitItemDetail(BuildContext context) async {
    String COCO_ID = (await Utility.getStringPreference(GlobalConstant.COCO_ID));
    List a1 = [];

    Map<String, dynamic> map3() => {
          'pname': 'Dids',
          'value': widget.data["did"].toString(),
        };

    Map<String, dynamic> dmap3 = map3();

    Map<String, dynamic> mapobj3() => {
          'cols': dmap3,
        };

    a1.add(mapobj3());

    Map<String, dynamic> map4() => {
          'pname': 'Typ',
          'value': widget.data["scanType"].toString(),
        };

    Map<String, dynamic> dmap4 = map4();
    Map<String, dynamic> mapobj4() => {
          'cols': dmap4,
        };

    a1.add(mapobj4());

    Map<String, dynamic> map1() => {
          'header': [],
          'name': 'param',
          'rowsList': a1,
        };
    Map<String, dynamic> data = map1();
    String userPass = (await Utility.getStringPreference(GlobalConstant.USER_PASSWORD));
    String USER_ID = (await Utility.getStringPreference(GlobalConstant.USER_ID));
    Map<String, dynamic> map2() => {
          'dbPassword': userPass,
          'dbUser': USER_ID,
          'host': GlobalConstant.host,
          'key': GlobalConstant.key,
          'os': GlobalConstant.OS,
          'procName': GlobalConstant.DocScan_SaveScanDoc_II,
          'rid': '',
          'srvId': GlobalConstant.SrvID,
          'timeout': GlobalConstant.TimeOut,
          'param': data,
        };
    ApiController apiController = ApiController.internal();
    if (await NetworkCheck.check()) {
      EasyLoading.show(status: 'loading...');
      try {
        Map<String, dynamic> data = await apiController.post(url: GlobalConstant.SignUp, input: map2());
        EasyLoading.dismiss();

        print("data-->$data");

        Map<String, dynamic> data1 = data;

        Utility.log(TAG, "Response: " + data1.toString());

        if (data1['status'] == 0) {
          // bool checkImage = false;
          // for (ImageModel im in imageModelList) {
          //   if (im.uploadStatus == 0) {
          //     checkImage = true;
          //     break;
          //   }
          // }
          // if (checkImage) {
          //   Dialogs.ackAlert(
          //     context,
          //     "Image pending to upload. Upload all images before close",
          //   );
          // } else {
          //   bool t = await showDialog<bool>(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text(
          //             'Confirm',
          //             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          //           ),
          //           content: Text("Are you sure?"),
          //           actions: <Widget>[
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.end,
          //               children: [
          //                 MaterialButton(
          //                   child: Text('NO'),
          //                   onPressed: () {
          //                     Navigator.of(context).pop(false);
          //                   },
          //                 ),
          //                 MaterialButton(
          //                   child: Text('YES'),
          //                   onPressed: () {
          //                     GlobalWidget.GetToast(context, "Data Closed Successfully");
          //                     Navigator.pop(context, true);
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ],
          //         );
          //       });
          //   if (t) {
          //     Navigator.pop(context);
          //   }
          // }

          Navigator.pop(context);
        } else {
          if (data1['msg'].toString() == "Login failed for user") {
            GlobalWidget.showMyDialog(context, "Error", "Invalid id or password.Please enter correct id psw or contact HR/IT");
          } else {
            print("ERROR---${data1['msg'].toString()}");
            GlobalWidget.showMyDialog(context, "Error", data1['msg'].toString());
          }
        }
      } catch (e) {
        Dialogs.hideProgressDialog(context);
        GlobalWidget.showMyDialog(context, "", GlobalConstant.interNetException(e.toString()));
      }
    } else {
      GlobalWidget.showToast(context, "No Internet Connection");
    }
  }

  TextEditingController quantityController = TextEditingController();
  String TAG = "ScanAndUpload";

  getUpdateBtn(BuildContext context) {
    return MaterialButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () async {
        Utility.log(TAG, _image);

        if (imageModelList.isEmpty) {
          GlobalWidget.showToast(context, "Please Take a picture...");
        } else {
          // EasyLoading.dismiss();
          EasyLoading.show(status: "Loading...");

          log("imageModelList--->${imageModelList.toString()}");

          for (int i = 0; i < imageModelList.length; i++) {
            if (imageModelList[i].uploadStatus == 0) {
              bool upload = await uploadImage(imageModelList[i].imagePath, i);
              if (upload) {
                imageModelList[i].uploadStatus = 1;
              } else {
                break;
              }
              // _asyncFileUpload(imageModelList[i].imagePath, i);
              // break;
            }
          }

          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
          }
        }
      },
      child: Text(
        'UPDATE',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  getCloseBtn(BuildContext context) {
    return MaterialButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () async {
        bool checkImage = false;
        for (ImageModel im in imageModelList) {
          if (im.uploadStatus == 0) {
            checkImage = true;
            break;
          }
        }
        if (checkImage) {
          Dialogs.ackAlert(
            context,
            "Image pending to upload. Upload all images before close",
          );
        } else {
          bool t = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Confirm',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  content: Text("Are you sure?"),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          child: Text('NO'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        MaterialButton(
                          child: Text('YES'),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              });

          if (t) {
            submitItemDetail(context);
          }
        }
      },
      child: Text(
        'CLOSE',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  getCameraBtn() {
    return MaterialButton(
      color: Colors.green,
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        if (imageModelList.length > 4) {
          GlobalWidget.showToast(context, "You can't take more images...");
        } else {
          clickImage();
        }
        setState(() {});
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera),
          Text(
            'Camera',
            style: GlobalWidget.textbtnstyle(),
          )
        ],
      ),
    );
  }

  Future<void> getData() async {
    COCO_NAME = (await Utility.getStringPreference(GlobalConstant.COCO_NAME));
    setState(() {});
  }

  openCompressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Compression between 20 to 100", textAlign: TextAlign.center),
          content: TextField(
            controller: _controller,
            //textInputAction: TextInputAction.done,
            // keyboardType: TextInputType.number,
            keyboardType: TextInputType.text,

            decoration: InputDecoration(labelText: 'Compression'),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
                _controller.text = "";
                setState(() {});
              },
            ),
            MaterialButton(
              child: Text("OK"),
              onPressed: () {
                if (int.parse(_controller.text.toString().trim()) == 20 || int.parse(_controller.text.toString().trim()) > 20) {
                  if (int.parse(_controller.text.toString().trim()) == 100 || int.parse(_controller.text.toString().trim()) < 100) {
                    setState(() {
                      Navigator.of(context).pop();
                      compressValue = _controller.text.toString().trim();
                      _controller.text = "";
                      // path = "";
                    });
                  } else {
                    Toast.show("Incorrect Value", context, gravity: Toast.CENTER);
                  }
                } else {
                  Toast.show("Incorrect Value", context, gravity: Toast.CENTER);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _CompressAndGetFile(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(file.path,
        quality: int.parse(compressValue.trim()), targetWidth: 960, targetHeight: 1280);

    print("_CompressAndGetFile 11 " + file.lengthSync().toString());
    print("_CompressAndGetFile 22 " + compressedFile.lengthSync().toString());
  }
}

class POScanModel {
  String Type = "Retry"; //"NewScan";
  String retryRmk = "";

  String Supplier;
  int IWID;
  int DID;
  int PoId;
  String DocNo;
  String DocDate;
  String InvoiceDt;
  String InvoiceNo;

  POScanModel(
      {this.Type,
      this.retryRmk,
      this.Supplier,
      this.IWID,
      this.DID,
      this.PoId,
      this.DocNo,
      this.DocDate,
      this.InvoiceDt,
      this.InvoiceNo});
}
