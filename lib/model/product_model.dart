class Product_Model {
  final String product_id;
  final String name;
  final int price;

  Product_Model({this.product_id, this.name, this.price});

  Map<String,dynamic> toMap(){
    return {
      'product_id': product_id,
    'name': name,
    'price': price };
  }

  Product_Model.fromFirestore(Map<String, dynamic> firestore): product_id=firestore['product_id'],
  name=firestore['name'],
  price=firestore['price'];

}
