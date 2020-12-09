class PriceModel {
  String quantity;
  String price;
  String kind;
  String unit;
  String id;

  PriceModel({this.kind, this.quantity , this.unit,this.price,this.id});

  Map<String, dynamic> toMap() {
    return {
      'price_id': id,
      'price_kind': kind,
      'quantity': quantity,
      'unit': unit,
      'price':price
    };
  }
}
