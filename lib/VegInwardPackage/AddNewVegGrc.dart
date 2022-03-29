import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ondoprationapp/DatabaseHelper/DatabaseHelper.dart';
import 'package:ondoprationapp/GlobalData/GlobalConstant.dart';
import 'package:ondoprationapp/GlobalData/GlobalWidget.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/GlobalSearchItem.dart';
import 'package:ondoprationapp/GlobalData/SearchItemAutoComplete/SearchItemModel.dart';
import 'package:ondoprationapp/GlobalData/Utility.dart';

class AddNewVegGrc extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewGrcData();
  }
}

class NewGrcData extends State<AddNewVegGrc> {
  final FocusNode _FMRPFocus = FocusNode();
  final FocusNode _FQTYFocus = FocusNode();
  final FocusNode _FFQTYFocus = FocusNode();
  final FocusNode _FSkFocus = FocusNode();
  final FocusNode _FGRemarkFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: GlobalWidget.getAppbar(GlobalWidget.GetAppName),
      body: getFirstForm(),
    );
  }

  var data1;
  getData(var data) {
    data1 = data;
  }

  getFirstForm() {
    return new ListView(
      padding: EdgeInsets.all(10.0),
      children: [
        ItemNameFeild(),
        Item_name == ""
            ? new Container()
            : InkWell(
                child: GlobalWidget.showItemName(Item_name),
                onTap: () {
                  GlobalConstant.OpenZoomImage(data1, context);
                },
              ),
        InwQtyFeild(),
        SizedBox(
          height: 20.0,
        ),
        GetSaveItemBtn()
      ],
    );
  }

  GetSaveItemBtn() {
    return RaisedButton(
      shape: GlobalWidget.getButtonTheme(),
      color: GlobalWidget.getBtncolor(),
      textColor: GlobalWidget.getBtnTextColor(),
      onPressed: () {
        //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UpdatePgiNumber()));
      },
      child: Text(
        'Save',
        style: GlobalWidget.textbtnstyle(),
      ),
    );
  }

  var InwQtyController = TextEditingController();
  InwQtyFeild() {
    return TextFormField(
      // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      //textInputAction: TextInputAction.done,
      focusNode: _FQTYFocus,

      maxLength: 5,
      onFieldSubmitted: (value) {
        GlobalWidget.fieldFocusChange(context, _FQTYFocus, _FFQTYFocus);
      },
      controller: InwQtyController,
      decoration: GlobalWidget.TextFeildDecoration1("Inward Quantity"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter Inward Quantity';
        }
        return null;
      },
    );
  }

  @override
  void initState() {
    getSearchItems();
  }

  GlobalKey<AutoCompleteTextFieldState<ModelSearchItem>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  static List<ModelSearchItem> SearchItems = new List<ModelSearchItem>();
  bool loading = true;
  void getSearchItems() async {
    List l1 = await DatabaseHelper.db.getAllPendingProducts1();
    if (l1.length < 0) {
      GlobalWidget.showToast(context, "Please wait untill data is sync");
    } else {
      //SearchItems = loadSearchItems(l1);
      SearchItems = GlobalSearchItem.loadSearchItems(l1.toString());
      // print('SearchItems: ${SearchItems[0].name}');
      setState(() {
        loading = false;
      });
    }
  }

  String SelectedListId = "";
  String Item_name = "";
  void onSelectItem(ModelSearchItem item) {
    Utility.log("tag", item.name);
    SelectedListId = item.id;

    Item_name = item.id + "  " + item.name;
    GlobalWidget.getItemDetail(context, SelectedListId, getData);
    setState(() {
      searchTextField.textField.controller.text = item.name;
    });
  }

  ItemNameFeild() {
    return loading
        ? new Container()
        : searchTextField = GlobalSearchItem.getAutoSelectionField(key, SearchItems, searchTextField, onSelectItem);
  }

/*
  var ItemNameController = TextEditingController();
  ItemNameFeild()
  {
    return TextFormField(
     // keyboardType: TextInputType.number,
      keyboardType: TextInputType.text,

      //textInputAction: TextInputAction.done,
      maxLength: 250,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      controller: ItemNameController,
      decoration: GlobalWidget.TextFeildDecoration1("ItemName/Barcode"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter';
        }
        return null;
      },
    );
  }*/
}
