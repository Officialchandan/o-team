
class ModelSearchStore {
  String id;
  String name;

  ModelSearchStore({this.id, this.name});

  factory ModelSearchStore.fromJson(Map<String, dynamic> parsedJson) {
    return ModelSearchStore(
      id: parsedJson["PID"],
      name: parsedJson["Pname"] as String,
    );
  }
}