class SubReviewModel {
  List<ReviewData> reviewDataList = List();

  SubReviewModel(this.reviewDataList);
}

class ReviewData {
  String reviewType = "";
  List<Review> review = List();

  ReviewData({this.reviewType, this.review});
}

class Review {
  String needImg = "";
  String maxScore = "";
  String score = "";
  String scoreRem = "";
  String paramId = "";
  String grp = "";
  String imagePath = "";
  String grade = "";
  String paramName = "";
  String empName = "";
  String subPoint = "";
  String remark = "";
  String new_remark = "";

  Review(
      {this.needImg,
      this.maxScore,
      this.score,
      this.scoreRem,
      this.paramId,
      this.grp,
      this.imagePath,
      this.grade,
      this.paramName,
      this.empName,
      this.subPoint,
      this.remark,
      this.new_remark});



}
