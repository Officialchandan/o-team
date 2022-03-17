
class ModelSearchItem {
  String id;
  String name;
  String Unit;

  ModelSearchItem({this.id, this.name, this.Unit});

  factory ModelSearchItem.fromJson(Map<String, dynamic> parsedJson) {
    return ModelSearchItem(
      id: parsedJson["ItId"],
      name: parsedJson["ItName"] as String,
      Unit: parsedJson["Unit"] as String,
    );
  }
}