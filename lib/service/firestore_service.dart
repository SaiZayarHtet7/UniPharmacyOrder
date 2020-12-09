import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_pharmacy_order/model/CategoryModel.dart';
import 'package:uni_pharmacy_order/model/NotiModel.dart';
import 'package:uni_pharmacy_order/model/OrderModel.dart';
import 'package:uni_pharmacy_order/model/PriceModel.dart';
import 'package:uni_pharmacy_order/model/ProductModel.dart';
import 'package:uni_pharmacy_order/model/product_model.dart';
import 'package:uni_pharmacy_order/model/user_model.dart';
import 'package:uni_pharmacy_order/model/VoucherModel.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream collectionStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  Stream documentStream =
      FirebaseFirestore.instance.collection('users').doc('ABC123').snapshots();

  Future<void> add(String collectionName, String dataName, String id) {
    CollectionReference users = _db.collection(collectionName);
    return users
        .doc('$id')
        .set({'$collectionName': '$dataName', 'id': '$id'})
        .then((value) => print("$collectionName Added"))
        .catchError((error) => print("Failed to add $collectionName: $error"));
  }

  Future<List> show(String collectionName) {
    CollectionReference users = _db.collection(collectionName);
    return users.snapshots().toList();
  }

  Future<void> update(String collectionName, String dataName, String id) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('$collectionName');
    return users
        .doc('$id')
        .update({'id': '$id', '$collectionName': '$dataName'})
        .then((value) => print("$collectionName Updated"))
        .catchError(
            (error) => print("Failed to update $collectionName: $error"));
  }

  Stream get(String collectionName) {
    CollectionReference users = _db.collection(collectionName);
    Stream collectionStream = users.snapshots();
    Stream documentStream = users.doc().snapshots();
    return collectionStream;
  }
  Stream getProduct(String category,String search) {
    CollectionReference products;
    products= _db.collection("product");
    Stream collectionStream;
    if( (category == "" || category =="All") && search== ""  ) {
   collectionStream = products.snapshots();
    }else{
      if(category=="" || category =="All" ){
        collectionStream = products.where('product_search',arrayContains: search).snapshots();
      }
      else if(search==""){
        collectionStream = products.where('category',isEqualTo: category).snapshots();
      }else {
        collectionStream =
            products.where('product_search', arrayContains: search).where(
                'category', isEqualTo: category).snapshots();
      }
      }
    Stream documentStream = products.doc().snapshots();

    return collectionStream;
  }

  Stream getPrice(String collectionName,String productId){
    CollectionReference users = _db.collection('product').doc(productId).collection(collectionName);
    Stream collectionStream = users.snapshots();
    return collectionStream;
  }

  Future<void> remove(String collectionName, String id) {
    CollectionReference users = _db.collection(collectionName);
    return users
        .doc('$id')
        .delete()
        .then((value) => print("$collectionName Deleted"))
        .catchError(
            (error) => print("Failed to delete $collectionName: $error"));
  }
  Future<void> removeVoucher(String collectionName, String id) {
    FirebaseFirestore.instance.collection('$collectionName').doc('$id').delete().whenComplete((){
      print('Field Deleted');
    });
    CollectionReference users = _db.collection(collectionName);
    return users
        .doc('$id')
        .delete()
        .then((value) => print("$collectionName Deleted"))
        .catchError(
            (error) => print("Failed to delete $collectionName: $error"));
  }






  Future<void> saveCategory(String collectionName,CategoryModel categoryModel) {
   CollectionReference reference= _db.collection('$collectionName');
        reference.doc(categoryModel.id)
                  .set(categoryModel.toMap()).then((value) => print("$collectionName added"))
   .catchError((error)=> print("failed to add $collectionName"));
  }
  Future<void> editCategory(String collectionName,CategoryModel categoryModel) {
    CollectionReference reference= _db.collection('$collectionName');
    reference.doc(categoryModel.id)
        .update(categoryModel.toMap()).then((value) => print("$collectionName update"))
        .catchError((error)=> print("failed to update $collectionName"));
  }

  Future<void> registerUser(String collectionName,UserModel model){
    CollectionReference reference= _db.collection('$collectionName');
    reference.doc(model.uid)
        .set(model.toMap()).then((value) => print("$collectionName added"))
        .catchError((error)=> print("failed to add $collectionName"));
  }

  Future<void> addProduct(String collectionName,ProductModel productModel){
    CollectionReference collectionReference= _db.collection('$collectionName');
    collectionReference.doc(productModel.productId)
        .set(productModel.toMap()).then((value) => print("$collectionName added"))
        .catchError((error)=> print("failed to add $collectionName"));
  }

  Future<void> editProduct(String collectionName,ProductModel productModel) {
    CollectionReference reference= _db.collection('$collectionName');
    reference.doc(productModel.productId)
        .update(productModel.toMap()).then((value) => print("$collectionName update"))
        .catchError((error)=> print("failed to update $collectionName"));
  }


  Future<void> addPrice(String collectionName,String productId,PriceModel priceModel){
    CollectionReference collectionReference= _db.collection('product').doc(productId).collection(collectionName);
    collectionReference.doc(priceModel.id)
        .set(priceModel.toMap()).then((value) => print("$collectionName added"))
        .catchError((error)=> print("failed to add $collectionName"));
  }

  Future<void> editPrice(String collectionName,String productId,PriceModel priceModel) {
    CollectionReference collectionReference= _db.collection('product').doc(productId).collection(collectionName);
    collectionReference.doc(priceModel.id )
        .update(priceModel.toMap()).then((value) => print("$collectionName update"))
        .catchError((error)=> print("failed to update $collectionName"));
  }

  Future<void> removePrice(String collectionName,String productId, String id) {
    CollectionReference users = _db.collection('product').doc(productId).collection(collectionName);
    return users
        .doc('$id')
        .delete()
        .then((value) => print("$collectionName Deleted"))
        .catchError(
            (error) => print("Failed to delete $collectionName: $error"));
  }

  Future<void> addOrder (String collectionName,String userId,OrderModel orderModel){
    CollectionReference collectionReference= _db.collection('user').doc(userId).collection(collectionName);
    collectionReference.doc(orderModel.orderId)
        .set(orderModel.toMap()).then((value) => print("$collectionName added"))
        .catchError((error)=> print("failed to add $collectionName"));
  }
  Future<void> editOrder(String collectionName,String userId,OrderModel orderModel) {
    CollectionReference collectionReference= _db.collection('user').doc(userId).collection(collectionName);
    collectionReference.doc(orderModel.orderId )
        .update(orderModel.toMap()).then((value) => print("$collectionName update"))
        .catchError((error)=> print("failed to update $collectionName"));
  }
  Future<void> removeOrder(String collectionName,String userId, String id) {
    CollectionReference users = _db.collection('user').doc(userId).collection(collectionName);
    return users
        .doc('$id')
        .delete()
        .then((value) => print("$collectionName Deleted"))
        .catchError(
            (error) => print("Failed to delete $collectionName: $error"));
  }

  Future<void> editVoucherOrder(String collectionName,String voucherId,OrderModel orderModel) {
    CollectionReference collectionReference= _db.collection('voucher').doc(voucherId).collection(collectionName);
    collectionReference.doc(orderModel.orderId )
        .update(orderModel.toMap()).then((value) => print("$collectionName voucher update"))
        .catchError((error)=> print("failed to update $collectionName"));
  }
  Future<void> removeVoucherOrder(String collectionName,String voucherId, String id) {
    CollectionReference users = _db.collection('voucher').doc(voucherId).collection(collectionName);
    return users
        .doc('$id')
        .delete()
        .then((value) => print("$collectionName Deleted"))
        .catchError(
            (error) => print("Failed to delete $collectionName: $error"));
  }

  Future<void> addVoucher(String collectionName,VoucherModel voucherModel){
    CollectionReference collectionReference= _db.collection('$collectionName');
    collectionReference.doc(voucherModel.voucherId)
        .set(voucherModel.toMap()).then((value) => print("$collectionName added"))
        .catchError((error)=> print("failed to add $collectionName"));
  }

  Future<void> addNoti(NotiModel notiModel){
    CollectionReference collectionReference= _db.collection('noti');
    collectionReference.doc(notiModel.notiId)
        .set(notiModel.toMap()).then((value) => print("noti added"))
        .catchError((error)=> print("failed to add noti"));
  }

}
