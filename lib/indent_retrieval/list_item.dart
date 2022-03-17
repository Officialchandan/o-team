import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/GlobalData/AppColor.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/indent_retrieval/IndentDetailClass.dart';

import '../GlobalData/GlobalWidget.dart';

class ItemListTile extends StatefulWidget {
  final Product product;
  final int index;
  final bool lockStatus;
  final Function(Product product) onUpdate;

  const ItemListTile({Key key, this.product, this.index, this.lockStatus, this.onUpdate}) : super(key: key);

  @override
  State<ItemListTile> createState() => _ItemListTileState();
}

class _ItemListTileState extends State<ItemListTile> {
  double retrivedQty = 0.0;
  double srtQty = 0.0;
  double total = 0.0;
  bool enablePlusMinus = false;

  String status = "PN";

  bool rt = true;
  bool prt = false;
  bool nf = false;

  String TAG = "IndentDetailActivity";
  List<Product> productItem = [];

  @override
  void initState() {
    retrivedQty = widget.product.qty;
    srtQty = widget.product.srtQty;
    total = widget.product.srtQty + widget.product.qty;
    status = widget.product.rtvst;

    print("widget.index${widget.index}");

    if (widget.index == 1) {
      rt = true;
      prt = false;
      nf = false;
    } else if (widget.index == 2) {
      rt = true;
      prt = false;
      nf = false;
    } else if (widget.index == 3) {
      rt = false;
      prt = true;
      nf = false;
    } else {
      rt = false;
      prt = false;
      nf = true;
    }
    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2),
      margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(style: BorderStyle.solid, width: 1.3),
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlobalWidget.getRowInsideDevide(),
          new Row(
            children: [
              Expanded(
                  flex: 2,
                  child: new Container(
                    child: CachedNetworkImage(
                      imageUrl: GlobalConstant.PhotoUrl + widget.product.imgpath,
                      errorWidget: (context, url, error) => Image.asset("assets/loading.png"),
                      fit: BoxFit.contain,
                    ),
                  )),
              Expanded(
                  flex: 8,
                  child: new Container(
                    padding: EdgeInsets.only(left: 10.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlobalWidget.getRowInsideDevide(),
                        new Text(
                          widget.product.itName,
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                          textAlign: TextAlign.left,
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            Expanded(
                              child: new Text(
                                "Barcode : " + widget.product.barcode,
                                style: TextStyle(color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              child: new Text(
                                "Stk : " + widget.product.stock,
                                style: TextStyle(color: Colors.black, fontSize: 11.0),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {});
                              },
                              child: new Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (enablePlusMinus && retrivedQty != 0.0) {
                                        retrivedQty = retrivedQty - 1.0;
                                        srtQty = srtQty + 1.0;

                                        setState(() {});
                                      }
                                    },
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: enablePlusMinus ? colorPrimary : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    retrivedQty.toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (enablePlusMinus && retrivedQty != total) {
                                        srtQty = srtQty - 1.0;

                                        retrivedQty = retrivedQty + 1.0;

                                        setState(() {});
                                      }
                                    },
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: enablePlusMinus ? colorPrimary : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    "SRT QTY : ${srtQty}",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        GlobalWidget.getRowInsideDevide(),
                        new Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: new Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      rt = true;
                                      prt = false;
                                      nf = false;

                                      retrivedQty = total;
                                      srtQty = 0.0;

                                      status = "RT";
                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          rt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: rt ? colorPrimary : Colors.grey,
                                        ),
                                        Text(
                                          "RT",
                                          style: TextStyle(color: rt ? colorPrimary : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (total != 1) {
                                        rt = false;
                                        prt = true;
                                        nf = false;
                                        enablePlusMinus = true;
                                        status = "PRT";
                                      }

                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          prt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: prt ? colorPrimary : Colors.grey,
                                        ),
                                        Text(
                                          "PRT",
                                          style: TextStyle(
                                            color: prt ? colorPrimary : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      rt = false;
                                      prt = false;
                                      nf = true;
                                      srtQty = total;
                                      retrivedQty = 0.0;
                                      status = "NF";

                                      setState(() {});
                                    },
                                    child: new Row(
                                      children: [
                                        Icon(
                                          nf ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                          color: nf ? colorPrimary : Colors.grey,
                                        ),
                                        Text(
                                          "NF",
                                          style: TextStyle(color: nf ? colorPrimary : Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  if (widget.lockStatus == true) {
                                    double qty = 0.0;

                                    print("ok--->${widget.product.rtvst}");
                                    if (status == "NF") {
                                      status = "NF";

                                      widget.product.qty = 0.0;
                                      widget.product.srtQty = srtQty;
                                      widget.product.sortQty = srtQty;
                                      widget.product.totalQty = total;
                                      widget.product.retrivedQty = retrivedQty;
                                      widget.product.rtvst = status;

                                      widget.onUpdate(widget.product);
                                    } else if (status == "RT") {
                                      status = "RT";
                                      widget.product.srtQty = srtQty;
                                      widget.product.qty = total;
                                      widget.product.sortQty = srtQty;
                                      widget.product.totalQty = total;
                                      widget.product.retrivedQty = retrivedQty;
                                      widget.product.rtvst = status;

                                      widget.onUpdate(widget.product);
                                    } else if (status == "PRT") {
                                      status = "PRT";
                                      if (srtQty == 0.0) {
                                        GlobalWidget.showMyDialog(context,
                                            "Short Qty Can't be zero for Partial Not Found.Use NF Option for all Item Not found", "");
                                      } else if (retrivedQty == 0.0) {
                                        GlobalWidget.showMyDialog(
                                            context,
                                            "",
                                            "Short Qty Can't be equalt to Qty for Partial Not Found.Use NF Option for all Item Not found"
                                                "");
                                      } else {
                                        // widget.product.retrivedQty = retrivedQty;
                                        // widget.product.srtQty = srtQty;
                                        widget.product.srtQty = srtQty;
                                        widget.product.sortQty = srtQty;
                                        widget.product.totalQty = total;
                                        widget.product.retrivedQty = retrivedQty;
                                        widget.product.qty = retrivedQty;
                                        widget.product.rtvst = status;

                                        widget.onUpdate(widget.product);
                                      }
                                    }
                                  } else {
                                    GlobalWidget.showMyDialog(context, "Alert", "Please Lock Order First ");
                                  }
                                },
                                child: new Container(
                                  width: 20.0,
                                  padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                                  child: Text(
                                    "Ok",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(5.0))),
                                ),
                              ),
                            )
                          ],
                        ),
                        GlobalWidget.getRowInsideDevide(),
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
