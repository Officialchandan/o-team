class ImageModel {
  int uploadStatus = 0;
  String imagePath = "";

  ImageModel(this.uploadStatus, this.imagePath);

  @override
  String toString() {
    return 'ImageModel{uploadStatus: $uploadStatus, imagePath: $imagePath}';
  }
}
