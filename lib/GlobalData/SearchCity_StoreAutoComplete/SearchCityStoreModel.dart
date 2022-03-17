
class ModelSearchCityStore {
  String id;
  String name;

  ModelSearchCityStore({this.id, this.name});

  factory ModelSearchCityStore.fromJson(Map<String, dynamic> parsedJson) {
    return ModelSearchCityStore(
      id: parsedJson["LocId"],
      name: parsedJson["Location"] as String,
    );
  }
}