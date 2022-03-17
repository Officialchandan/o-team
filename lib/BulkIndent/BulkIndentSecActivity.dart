import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/BulkIndent/BulkIndentRetrival.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';

class BulkIndentSecActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BulkIndentSecView();
  }
}

class BulkIndentSecView extends State<BulkIndentSecActivity> {
  List<int> secId = [1, 2, 3, 5, 7, 6, 4, 8, 0];

  List<String> secName = [
    "Aata/Flour",
    "Air Care",
    "Biscuits/Chips",
    "Coffee/Spices/Tea",
    "Cosmetics",
    "Detergent",
    "Drink",
    "Frozen",
    "No Sec"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getWidget(),
    );
  }

  getWidget() {
    return ListView.builder(
      itemCount: secName.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => BulkIndentRetrival(secId[index], secName[index])));
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Align(alignment: Alignment.center, child: Text(secName[index])),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  )
                ],
              )),
        );
      },
    );
  }
}
