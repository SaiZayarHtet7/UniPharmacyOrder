import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/model/OrderModel.dart';
import 'package:uni_pharmacy_order/service/firestore_service.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/order/OrderPage.dart';
import 'package:uni_pharmacy_order/view/product/ProductPage.dart';
import 'package:uni_pharmacy_order/view/voucher/VoucherOrder.dart';
import 'package:uni_pharmacy_order/view/voucher/VoucherPage.dart';
import 'package:uni_pharmacy_order/widget/TitleTextColor.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ProductOrder extends StatefulWidget {
  final String productName,productImage,productId,orderId,quantity,newUnit,oldCost,kind,voucherId,voucherNumber;

  const ProductOrder(this.kind,this.voucherId,this.voucherNumber, this.productId, this.productName, this.productImage,this.orderId,this.quantity,this.newUnit,this.oldCost);

  @override
  _ProductOrderState createState() => _ProductOrderState(kind,voucherId,voucherNumber,productId,productName,productImage,orderId,quantity,newUnit,oldCost);
}

class _ProductOrderState extends State<ProductOrder> {
  String userId;
  String productName,productImage,productId,orderId,newUnit,oldCost,kind,voucherId,voucherNumber;
  _ProductOrderState(this.kind,this.voucherId,this.voucherNumber,this.productId, this.productName,this.productImage,this.orderId,this.quantity,this.newUnit,this.oldCost);
  List<String> unitList=new List();
  List<String> uniqueUnitList=new List();
  String unit;
  final quantityController=TextEditingController();
  String cost;
  String quantity;
  var uuid=Uuid();
  int orderCount;

  bool validate;

  fetchData() async {
    SharedPreferences pref= await SharedPreferences.getInstance();
    userId=pref.getString("uid");
    print('user id is >>>$userId');
    print('productId'+productId);
    print('cost' + oldCost);
    FirebaseFirestore.instance.collection("product").doc(productId).collection("price").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          unitList.add(result.data()['unit'].toString());
          print(unitList);
         uniqueUnitList= LinkedHashSet<String>.from(unitList).toList();
        print(uniqueUnitList);
        });
      });
    });
  }

  Future<bool> _onWillPop() async {
    if(orderId=="" || orderId==null) {
      Navigator.of(context).pop();
    }else{
      if(kind=="order"){
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => OrderPage()));
      }
      else{
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => VoucherOrder(voucherId, voucherNumber)));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      fetchData();
    });
    if(orderId=="" || orderId == null){
      cost="0";
    }else{
      quantityController.text=quantity;
      cost=oldCost;
      unit=newUnit;
    }
    validate=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leading:IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,), onPressed: (){
            if(orderId=="" || orderId==null) {
              Navigator.of(context).pop();
            }else{
              if(kind=="order"){
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => OrderPage()));
              }
              else{
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => VoucherOrder(voucherId, voucherNumber)));
              }
            }
          }) ,
          title:Text('ပစ္စည်းအဝယ်စာရင်းသွင်းမည်'), toolbarHeight: 70,backgroundColor: Constants.thirdColor,),
        body: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1,color: Constants.thirdColor
                    ),
                    shape: BoxShape.circle,
                  ),
                  child:Center(
                    child: CachedNetworkImage(
                      imageUrl: productImage,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 120.0,
                        height: 120.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),
                Container(
                  width: MediaQuery.of(context).size.width,
                    child: Text('$productName',textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color: Constants.primaryColor,fontWeight: FontWeight.bold,fontFamily: Constants.PrimaryFont),)),
                SizedBox(height: 40.0,),
                Table(
                  border: TableBorder.all(width: 0.0,color: Colors.white),
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(width: 100,
                                  child: Text("အရေအတွက်",style: TextStyle(color: Colors.black,fontSize: 16),)),
                              SizedBox(width: 10.0,),
                              ClipOval(
                                child: Material(
                                  color: Constants.thirdColor, // button color
                                  child: InkWell(
                                    splashColor: Constants.primaryColor, // inkwell color
                                    child: SizedBox(width: 40, height: 40, child: Icon(Icons.remove,color: Colors.white,)),
                                    onTap: () {
                                      if(quantityController.text=="" || quantityController.text=="0"){

                                      }else{
                                        int numInt=int.parse(quantityController.text);
                                        int changeNum=numInt-1;
                                        setState(() {
                                          quantityController.text=changeNum.toString();
                                          calculatorPrice(quantityController.text, unit);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Flexible(
                                child: TextFormField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      fontFamily: Constants.PrimaryFont
                                  ),
                                  onChanged: (value){
                                    quantity=value;
                                    print(quantity);
                                    setState(() {
                                      calculatorPrice(quantity, unit);
                                    });
                                  },
                                  decoration: InputDecoration(
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide:new BorderSide(color: Constants.primaryColor),
                                      ),
                                      focusedBorder: new OutlineInputBorder(
                                          borderSide: new BorderSide(color: Constants.primaryColor)
                                      ),
                                      border: new OutlineInputBorder(
                                        borderSide: new BorderSide(color: Constants.primaryColor),
                                      )
                                  ) ,
                                ),
                              ),SizedBox(width: 10,),
                              ClipOval(
                                child: Material(
                                  color: Constants.thirdColor, // button color
                                  child: InkWell(
                                    splashColor: Constants.primaryColor, // inkwell color
                                    child: SizedBox(width: 40, height: 40, child: Icon(Icons.add,color: Colors.white,)),
                                    onTap: () {
                                      if(quantityController.text==""){
                                        quantityController.text="1";
                                      }
                                      else{
                                        int numInt=int.parse(quantityController.text);
                                        int changeNum=numInt+1;
                                        setState(() {
                                          quantityController.text=changeNum.toString();
                                          calculatorPrice(quantityController.text,unit);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                         TableCell(
                          child: Row(
                            children: [
                              SizedBox(height: 10.0,)
                            ],
                          ),
                        ),
                      ]
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width:100.0,
                                  child: Text("Unit",style: TextStyle(color: Colors.black,fontSize: 16),)),
                              SizedBox(width: 10.0,),
                               Flexible(
                                child: DropdownButtonFormField<String> (
                                  decoration:  InputDecoration(
                                      labelText: 'unit',
                                      labelStyle: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,),
                                      enabledBorder: new OutlineInputBorder(
                                        borderSide:new BorderSide(color: Constants.primaryColor),
                                      ),
                                      focusedBorder: new OutlineInputBorder(
                                          borderSide: new BorderSide(color: Constants.primaryColor)
                                      ),
                                      border: new OutlineInputBorder(
                                        borderSide: new BorderSide(color: Constants.primaryColor),
                                      )
                                  ) ,
                                  value:unit,
                                  // value: categorySelected,
                                  items: uniqueUnitList.map((label){
                                    return DropdownMenuItem(
                                      child: Text(
                                        label,
                                        style:
                                        TextStyle(height: -0.0,color: Colors.black,fontFamily: Constants.PrimaryFont),
                                      ),
                                      value: label,
                                    );
                                  }
                                  ).toList(),
                                  onChanged: (value) {
                                    List<String> priceList =new List();
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    unit = value.toString();
                                    print(unit);
                                    setState(() {
                                      calculatorPrice(quantityController.text,unit);
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ]
                    ),
                    TableRow(
                        children: [
                          TableCell(
                            child: Row(
                              children: [
                                SizedBox(height: 20.0,)
                              ],
                            ),
                          ),
                        ]
                    ),
                    TableRow(
                        children: [
                          TableCell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width:100.0,
                                    child: Text("ကျသင့်ငွေ",style: TextStyle(color: Colors.black,fontSize: 16),)),
                                SizedBox(width: 10.0,),
                            Row(
                              children: [
                                Container(
                                          child:Text(Constants().oCcy.format(double.parse(cost))+".00",style: TextStyle(color: Constants.thirdColor,fontSize: 20),),
                                      ),
                                SizedBox(width: 10.0,),
                                Text("ကျပ်",style: TextStyle(color: Colors.black,fontSize: 18),),
                              ],
                            )
                              ],
                            ),
                          )
                        ]
                    ),
                  ],
                ),
                SizedBox(height: 10.0,),
                (validate==true || orderId !=null && orderId != "") ? Container(
                  margin: EdgeInsets.all(10),
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: () async {
                      print('clicked');
                      if(quantityController.text=="" || quantityController.text==" " || quantityController.text== null || quantityController.text=="0" || unit=="" || unit == null)
                        {
                          _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                backgroundColor: Constants.emergencyColor,
                                content: Text('ဒေတာအမှန်ထည့်ပေးပါ'),
                                duration: Duration(seconds: 3),
                              ));
                        }else{
                        print("cost is "+cost.toString());
                        String newOrderId=uuid.v4();
                        if(orderId=="" || orderId==null) {
                          OrderModel orderModel = OrderModel(
                              productId: productId,
                              productName: productName,
                              productImage: productImage,
                              quantity: quantityController.text,
                              unit: unit.toString(),
                              cost: cost,
                              orderId: newOrderId
                          );
                          FirestoreService().addOrder("order", userId, orderModel);

                          _scaffoldKey.currentState
                              .showSnackBar(SnackBar(
                            content: Text('အဝယ်စာရင်း သွင်းပြီးပါပြီ'),
                            duration: Duration(seconds: 2),
                            backgroundColor:Colors.greenAccent,
                          ));

                          ///To ask user to order///
                          ///
                          ///
                          ///
                          ///
                          ///
                          showDialog(
                            context: context,
                            builder:(BuildContext context){
                              return AlertDialog(
                                title: Text( 'ဝယ်ထားသော စာရင်းများ',
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Constants.thirdColor,fontFamily: Constants.PrimaryFont)),
                                content: Container(
                                  height: 200.0,
                                  width: 300.0,
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('user').doc(userId).collection('order').snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Something went wrong');
                                      }
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text("Loading");
                                      }
                                      return new ListView(
                                        shrinkWrap: true,
                                        children: snapshot.data.documents.map((DocumentSnapshot document) {
                                          return new ListTile(
                                            title: Text(document.data()['product_name'],style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont,fontSize: 15),),
                                            subtitle: new Text(document.data()['quantity'] +"  "+document.data()['unit']),
                                            trailing: Text( Constants().oCcy.format(double.parse(document.data()['cost'])).toString() + ".00 ကျပ်", style: TextStyle(color: Constants.thirdColor, fontFamily: Constants.PrimaryFont, fontSize: 14)),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('အဝယ်စာရင်းသို့သွားမည်',
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            color: Constants.primaryColor,
                                            fontFamily: Constants.PrimaryFont
                                        ),
                                        textAlign: TextAlign.right),
                                    onPressed: () async {
                                      Navigator.pushAndRemoveUntil(
                                          context, MaterialPageRoute(builder: (context) => OrderPage()),
                                            (route) => false,);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('ဆေးပစ္စည်းများ ဆက်မှာမည်',
                                        style: new TextStyle(
                                            fontSize: 16.0,
                                            color: Constants.primaryColor,
                                            fontFamily: Constants.PrimaryFont
                                        ),
                                        textAlign: TextAlign.right),
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => ProductPage(),
                                        ),
                                            (route) => false,
                                      );
                                      // Navigator.pop(context);
                                    },
                                  )
                                ],
                              );
                            }
                          );

                        }
                        else{
                          OrderModel orderModel = OrderModel(
                              productId: productId,
                              productName: productName,
                              productImage: productImage,
                              quantity: quantityController.text,
                              unit: unit.toString(),
                              cost: cost,
                              orderId: orderId
                          );
                          if(kind=="order"){
                            FirestoreService().editOrder("order", userId, orderModel);
                            _scaffoldKey.currentState
                                .showSnackBar(SnackBar(
                              content: Text( 'အဝယ်စာရင်း ပြင်ဆင်ပြီးပါပြီ'),
                              duration: Duration(seconds: 2),
                              backgroundColor:Colors.greenAccent,
                            ));
                            Future.delayed(const Duration(milliseconds: 500), () {
                              setState(() {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderPage()),
                                );
                              });
                            });
                          }else{
                            FirestoreService().editVoucherOrder("order", voucherId, orderModel);
                            _scaffoldKey.currentState
                                .showSnackBar(SnackBar(
                              content: Text( 'အဝယ်စာရင်း ပြင်ဆင်ပြီးပါပြီ'),
                              duration: Duration(seconds: 2),
                              backgroundColor:Colors.greenAccent,
                            ));
                            Future.delayed(const Duration(milliseconds: 500), () {
                              setState(() {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => VoucherOrder(voucherId,voucherNumber)),
                                );
                              });
                            });
                          }

                        }
                      }
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0),),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Hexcolor('#fd9346'),Constants.primaryColor,Hexcolor('#fd9346'),],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)
                      ),
                      child: Container(
                        constraints: BoxConstraints(minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text((orderId==null || orderId =="") ?'အဝယ်စာရင်းသွင်းမည်' :"အဝယ်စာရင်း ပြင်မည် ",style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                      ),
                    ),
                  ),
                ) :
               RaisedButton(
                 onPressed: (){
                   if(orderId=="" || orderId == null) {
                     _scaffoldKey.currentState.showSnackBar(
                         SnackBar(
                           backgroundColor: Constants.emergencyColor,
                           content: Text('ဒေတာအမှန်ထည့်ပေးပါ'),
                           duration: Duration(seconds: 3),
                         ));
                   }else{
                     _scaffoldKey.currentState.showSnackBar(
                         SnackBar(
                           backgroundColor: Constants.emergencyColor,
                           content: Text('ဒေတာ မပြင်ရသေးပါ'),
                           duration: Duration(seconds: 3),
                         ));
                   }
                 },
                 padding: EdgeInsets.all(0.0),
                 child: Ink(
                   decoration: BoxDecoration(color: Colors.white),
                   child: Container(
                     constraints: BoxConstraints(minHeight: 50.0),
                     alignment: Alignment.center,
                     child: Text('အဝယ်စာရင်းသွင်းမည်', style: TextStyle(color: Constants.primaryColor,fontSize: 18.0,fontFamily:Constants.PrimaryFont),
                     ),
                   ),
                 ),
                 textColor: Colors.white,
                 shape: RoundedRectangleBorder(side: BorderSide(
                     color: Constants.primaryColor,
                     width: 1,
                     style: BorderStyle.solid
                 ), borderRadius: BorderRadius.circular(80)),
               ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  calculatorPrice(String quan,String unit,){
    List<int> priceList=new List();
    int calQuantity=int.parse(quan);
    String category;
    if(quan=="" || quan==null || unit=="" || unit == null || quan =="0"){
      setState(() {
        cost = "0";
        validate=false;
      });
    }
    else {
      setState(() {
        validate=true;
      });
      print("cal quan" +calQuantity.toString() );
      print("cal unit" +unit );
      FirebaseFirestore.instance.collection("product").doc(productId)
          .collection("price")
          .where("unit", isEqualTo: unit)
          .where("quantity", isLessThanOrEqualTo: calQuantity).get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          setState(() {
            if (quan == "0") {
              setState(() {
                cost = "0";
              });
            } else {
              priceList.add(int.parse(result.data()['price']));
              priceList.sort();
              print("Calculated price"+priceList[priceList.length-1].toString());
              double tempCost = (calQuantity / result.data()['quantity']) *
                  priceList[priceList.length-1];
              cost = tempCost.toString();
              print(tempCost.toString());
            }
          });
        });
      });
    }
  }
}
