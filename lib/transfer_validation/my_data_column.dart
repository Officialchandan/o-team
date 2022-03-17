class MyDataColumn {
  String name;
  String type;
  String xmlnstype = "xsi:type=\"xs:string\"";
  String xmlns =
      "xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"";

  MyDataColumn(String name, String type) {
    this.name = name;
    this.type = type;
  }
  String getName() {
    return name;
  }

  void setName(String name) {
    this.name = name;
  }

  String toXml() {
    return "<" + name + "  " + xmlnstype + "  " + xmlns + " >";
  }

  String getType() {
    return type;
  }

  Map<String,dynamic> toJson(){

    Map<String,dynamic> map = {

      "name": getName(),
      "type":getType(),
      "xmlnstype":xmlnstype,
      "xmlns":xmlns
    };
    return map;


  }

  void setType(String type) {
    xmlnstype = "xsi:type=\"xs:" + type.toLowerCase() + "\"";
    this.type = type;
  }
}
