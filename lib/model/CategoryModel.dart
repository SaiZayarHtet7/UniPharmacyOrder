class CategoryModel {
  String categoryName;
  String categoryImage;
  String id;

  CategoryModel({this.categoryName, this.categoryImage, this.id});

  Map<String, dynamic> toMap() {
    return {
      'category_name': categoryName,
      'category_image': categoryImage,
      'id': id,
    };
  }
}
