class OrderModel {

  String productId;
  String productName;
  String productImage;
  String quantity;
  String unit;
  String cost;
  String orderId;

  OrderModel({this.productId, this.productName , this.productImage,this.quantity,this.unit,this.cost,this.orderId});

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name':productName ,
      'product_image': productImage,
      'quantity':quantity,
      'unit': unit,
      'cost':cost,
      'order_id':orderId
    };
  }
}
