import 'dart:collection';

import 'package:ondoprationapp/transfer_validation/data_table.dart';

class MyDataRow {
  HashMap<String, Object> cols = new HashMap();
  MyDataTable parentTbl;

  void add(String key, Object val) {
    cols.putIfAbsent(key, () => val);
  }

  Object get(String key) {
    Object obj = cols.keys;
    if (obj == null) return "";
    return obj;
  }

  Object getN(String key) {
    return cols[key];
  }

  Object get1(int i) {
    Set<String> set = cols.values;
    List<String> keys = set.toList();
    return cols[keys[i]];
  }

  Object item(String key) {
    return get(key);
  }

  HashMap<String, Object> getCols() {
    return cols;
  }

  void setCols(HashMap<String, Object> cols) {
    this.cols = cols;
  }

  Map<String, dynamic> toJosn() {
    Map<String, dynamic> map = {"cols": getCols()};
    return map;
  }

  MyDataRow add1(List<Object> val) {
    if (parentTbl == null)
      throw new Exception("Parent DataTable Must not be Null.");
    for (int i = 0; i < val.length; i++) {
      // cols.put(parentTbl.getHeader().get(i).getName(), val[i]);
      parentTbl.getHeader()[i].getName()..endsWith(val[i]);
    }
    return this;
  }

  String toString() {
    return "DataRow{" +
        "cols=" +
        cols.toString() +
        ", parentTbl=" +
        parentTbl.toString() +
        '}';
  }
}
