
class ModelSearchCity {
  String id;
  String name;

  ModelSearchCity({this.id, this.name});

  factory ModelSearchCity.fromJson(Map<String, dynamic> parsedJson) {
    return ModelSearchCity(
      id: parsedJson["CityId"],
      name: parsedJson["CityLbl"] as String,
    );
  }
}