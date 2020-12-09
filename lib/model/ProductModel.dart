class ProductModel {
  String productId;
  String productName;
  String description;
  String productImage;
  String category;
  String discount;
  List<String> productSearch;

  ProductModel(
      { this.productId,
        this.productName,
        this.description,
        this.productImage,
        this.category,
        this.discount,
        this.productSearch,
      });

  Map<String, dynamic> toMap() {
    return {
      'product_id':productId,
      'product_name':productName,
      'description':description,
      'product_image':productImage,
      'category':category,
      'discount':discount,
      'product_search':productSearch
    };
  }
}

