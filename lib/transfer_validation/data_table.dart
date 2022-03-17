import 'package:ondoprationapp/transfer_validation/my_data_row.dart';

import 'my_data_column.dart';

class MyDataTable {
  List<MyDataRow> rowsList = [];
  List<MyDataColumn> header = [];

  String name;

  MyDataTable(String name) {
    this.name = name;
  }

  void addRow(MyDataRow row) {
    rowsList.add(row);
  }

  int rowCount() {
    print("rowsList.length ${rowsList.length}");
    return rowsList.length;
  }

  MyDataRow getRow(int i) {
    return rowsList[i];
  }

  void clear() {
    rowsList.clear();
  }

  List<MyDataColumn> getHeader() {
    print("header-->${header.length}");
    return header;
  }

  void setHeader(List<MyDataColumn> header) {
    this.header = header;
  }

  String getName() {
    print("Name-->${name.length}");
    name = "param";
    return name;
  }

  void setName(String Name) {
    print("Name-->${Name.length}");
    this.name = Name;
  }

  List<MyDataRow> getRowsList() {
    return rowsList;
  }

  void setRowsList(List<MyDataRow> rowsList) {
    this.rowsList = rowsList;
  }

  String toXml() {
    String xml = "<DocumentElement>";

    for (int i = 0; i < rowsList.length; i++) {
      xml += "<Param>";
      MyDataRow dr = rowsList[i];
      for (int j = 0; header != null && j < header.length; j++) {
        xml += header[j].toXml() +
            "" +
            dr.get1(header[i].getName().hashCode) +
            "</" +
            header[j].getName() +
            ">";
      }

      xml += "</Param>";
    }

    xml += "</DocumentElement>";

    return xml;
  }

  void addColumns(String fld, String typ) {
    MyDataColumn dc = MyDataColumn(fld, typ);
    dc.setName(fld);
    dc.setType(typ);
    header.add(dc);
  }

  MyDataRow newRow() {
    MyDataRow dr = new MyDataRow();
    dr.parentTbl = this;
    print("dr--$dr");
    return dr;
  }

  MyDataRow rows(int i) {
    return rowsList[i];
  }

  void removeRow(int i) {
    rowsList.remove(i);
  }


  Map<String,dynamic> toJson(){
    Map<String,dynamic> map = {
      "rowsList": getRowsList()==null?[]:getRowsList().map((e) => e.toJosn()).toList(),
      "header" : getHeader()==null?[]:getHeader().map((e) => e.toJson()).toList(),
      "name":getName()
    };
    return map;
}

}
