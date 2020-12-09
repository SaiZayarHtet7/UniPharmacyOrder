import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/model/NotiModel.dart';
import 'package:uni_pharmacy_order/service/NotiService.dart';
import 'package:uni_pharmacy_order/service/firestore_service.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/product/ProductOrder.dart';
import 'package:uni_pharmacy_order/view/voucher/VoucherPage.dart';
import 'package:uni_pharmacy_order/widget/TextData.dart';
import 'package:uni_pharmacy_order/widget/TextDataColor.dart';
import 'package:uni_pharmacy_order/widget/TitleTextColor.dart';
import 'package:uuid/uuid.dart';


class VoucherOrder extends StatefulWidget {
  final String voucherId,voucherNumber;

  const VoucherOrder(this.voucherId,this.voucherNumber);

  @override
  _VoucherOrderState createState() => _VoucherOrderState(voucherId,voucherNumber);
}

class _VoucherOrderState extends State<VoucherOrder> {

  ///declaration
  String voucherId,voucherNumber;
  _VoucherOrderState(this.voucherId,this.voucherNumber);
  String date;
  bool isLoading;
  double totalCost;
  int orderCount;
  String status,userName,userId,voucherDate,voucherTime,userPhoto;
  final ScrollController  scrollController = ScrollController();
  var uuid=Uuid();


  ///for initstate
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading=true;
    });
    fetchData();
    setState(() {
      isLoading=false;
    });
  }


  void fetchData() async{
    print(voucherId);
    totalCost=0.0;
    FirebaseFirestore.instance.collection("voucher").doc(voucherId).collection("order").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          totalCost = totalCost + double.parse(result.data()['cost']);
          print(totalCost.toString());
        });
      });
    });

    SharedPreferences preferences= await SharedPreferences.getInstance();
    userName=preferences.getString('user_name');
    userId=preferences.getString('uid');
    userPhoto=preferences.getString('user_photo');


    FirebaseFirestore.instance.collection("voucher").doc(voucherId).collection('order').get().then((value){
      orderCount = value.docs.length;
      print('number of order'+orderCount.toString());
    });

    FirebaseFirestore.instance.collection("voucher").doc(voucherId).get().then(
            (value) {
              setState(() {
                status= value.data()['status'].toString();
                voucherDate=value.data()['date_time'].toString().substring(0,10);
                voucherTime=value.data()['date_time'].toString().substring(11,value.data()['date_time'].toString().length);
              });
            }
    );
  }
  @override
  Widget build(BuildContext context) {

    String convertVoucher(String vNo){
      do{
        vNo="0"+vNo;
      }while(vNo.length<5);
      return  vNo;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,), onPressed: (){
          Navigator.of(context).pop();
        }),
        toolbarHeight: 70,
        backgroundColor: Constants.thirdColor,
        title: Text('ဘောက်ချာအမှတ် ${convertVoucher(voucherNumber)}'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2,
                    child: Center(child: TitleTextColor("ရက်စွဲ", Constants.thirdColor))),
                Expanded( flex: 1,
                    child: SizedBox()),
                Expanded(flex: 2,
                    child: Center(child: TitleTextColor("အချိန်", Constants.thirdColor))),
              ],
            ),
            SizedBox(height: 10.0,),
            voucherTime==null?Center(child: CircularProgressIndicator(),):
             Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2,
                    child: Center(child: TextData(voucherDate))),
                Expanded( flex: 1,
                    child: SizedBox()),
                Expanded(flex: 2,
                    child: Center(child: TextData(voucherTime))),
              ],
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20),
                child: Scrollbar(
                  controller: scrollController,
                  isAlwaysShown: true,

                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('voucher').doc(voucherId).collection("order").snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if(snapshot.hasData){
                          return Container(
                            child:DataTable(
                              horizontalMargin: 3,
                              columnSpacing: 10,
                              columns: [
                                DataColumn(label: TextDataColor('အမျိုးအမည်')),
                                DataColumn(label: TextDataColor('အရေအတွက်')),
                                DataColumn(label: TextDataColor('ယူနစ်')),
                                DataColumn(label: Expanded(child: Align(alignment: Alignment.centerRight,child: Text("သင့်ငွေ",textAlign: TextAlign.right,style: TextStyle(color: Constants.thirdColor,fontSize: 13,fontFamily: Constants.PrimaryFont))))),
                                DataColumn(label: Text('')),
                                DataColumn(label: Text('')),
                              ],
                              rows: snapshot.data.documents.map((data) {
                                return DataRow(
                                    cells: [
                                      DataCell(TextData(data.data()['product_name'])),
                                      DataCell(Align(alignment: Alignment.centerRight,child: TextData(data.data()['quantity']))),
                                      DataCell(Align(alignment: Alignment.centerLeft,child: TextData(data.data()['unit']))),
                                      DataCell(Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(Constants().oCcy.format(double.parse(data.data()['cost'])).toString() + ".00", style: TextStyle(color: Constants.primaryColor, fontFamily: Constants.PrimaryFont, fontSize: 14),))),
                                     status!=Constants.orderDeliver? DataCell(ClipOval(
                                        child: Material(
                                          color: Colors.blue,
                                          // button color
                                          child: InkWell(
                                            splashColor: Colors.red,
                                            // inkwell color
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .all(8.0),
                                              child: SizedBox(
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 25,
                                                    color: Colors
                                                        .white,)),
                                            ),
                                            onTap: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => ProductOrder('voucher',voucherId,voucherNumber, data.data()['product_id'],data.data()['product_name'],data.data()['product_image'],data.data()['order_id'],data.data()['quantity'],data.data()['unit'],data.data()['cost'])),
                                              );
                                            },
                                          ),
                                        ),
                                      )):DataCell( Text('')),
                                      status!=Constants.orderDeliver? DataCell(ClipOval(child: Material(
                                        color: Constants
                                            .emergencyColor,
                                        // button color
                                        child: InkWell(
                                          splashColor: Colors.red,
                                          // inkwell color
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .all(8.0),
                                            child: SizedBox(
                                                child: Icon(Icons
                                                    .delete_forever,
                                                  size: 25,
                                                  color: Colors
                                                      .white,)),
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text( 'ဖျက်ရန် သေချာပါသလား?',
                                                    style: new TextStyle(
                                                        fontSize: 20.0, color: Constants.thirdColor,fontFamily: Constants.PrimaryFont)),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('ဖျက်မည်',
                                                        style: new TextStyle(
                                                            fontSize: 16.0,
                                                            color: Constants.primaryColor,
                                                          fontFamily: Constants.PrimaryFont
                                                        ),
                                                        textAlign: TextAlign.right),
                                                    onPressed: () async {
                                                      setState(() {
                                                        if(orderCount == 1 ){
                                                          FirebaseFirestore.instance.collection("voucher").doc(voucherId).collection('order').get().then((snapshot) {
                                                            for (DocumentSnapshot doc in snapshot.docs) {
                                                              doc.reference.delete();
                                                            }
                                                            print("delete");
                                                          });
                                                          FirestoreService().removeVoucher("voucher", voucherId);
                                                          NotiService().sendNoti('Order Cancel Alert','$userName မှ အော်ဒါ cancel ဖြစ်သွားသည်' );


                                                          NotiModel notiModel= NotiModel(
                                                            notiId: uuid.v4(),
                                                            notiTitle: "အမှာစာ ပယ်ဖျက်ခြင်း",
                                                            notiText: "$userName မှ အမှာစာ ပယ်ဖျက်လိုက်ပါသည် (Voucher Number=${ convertVoucher(voucherNumber.toString()) })",
                                                            notiType: 'unread',
                                                            createdDate: DateTime.now().millisecondsSinceEpoch,
                                                            sender: userId,
                                                            photo: userPhoto,
                                                          );

                                                          FirestoreService().addNoti(notiModel);

                                                          Fluttertoast.showToast(msg: "အော်ဒါ cancel ဖြစ်သွားသည်" ,toastLength: Toast.LENGTH_LONG,backgroundColor: Constants.thirdColor);
                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => VoucherPage()),
                                                          );
                                                        }else {
                                                          totalCost = totalCost -
                                                              double.parse(
                                                                  data.data()['cost']);
                                                          --orderCount;
                                                          Navigator.pop(context);
                                                        }
                                                      });
                                                      FirestoreService().removeVoucherOrder("order", voucherId, data.data()['order_id']);
                                                      Fluttertoast.showToast(msg: "ဖျက်ပြီးပါပြီ" ,toastLength: Toast.LENGTH_LONG,backgroundColor: Constants.thirdColor);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text('မဖျက်ပါ',
                                                        style: new TextStyle(
                                                            fontSize: 16.0,
                                                            color: Constants.primaryColor,
                                                            fontFamily: Constants.PrimaryFont
                                                        ),
                                                        textAlign: TextAlign.right),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      )):DataCell( Text('')),
                                    ]
                                );
                              },
                              ).toList(),
                            ),
                          );
                        }else{
                          return TitleTextColor("No data", Constants.thirdColor);
                        }
                      }),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround ,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(height: 50.0,
                      child: Text("စုစုပေါင်း  ",textAlign: TextAlign.right,style: TextStyle(fontSize: 18,fontFamily: Constants.PrimaryFont,color: Constants.thirdColor),)),
                ),
                SizedBox(width: 10.0,),
                Expanded(
                  flex: 2,
                  child: Container(height: 50,
                      child: Text(Constants().oCcy.format(totalCost)+" ကျပ်",style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold,fontSize: 18),)),
                ),
              ],
            ),
            SizedBox(height: 20.0,),
           status==Constants.orderDeliver? SizedBox(): Container(
              height: 50.0,
              child: RaisedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text( 'အော်ဒါကို ပယ်ဖျက်ရန် သေချာပါသလား?',
                          style: new TextStyle(
                              fontSize: 20.0, color: Constants.thirdColor,fontFamily: Constants.PrimaryFont)),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('ဖျက်မည်',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Constants.primaryColor,
                                  fontFamily: Constants.PrimaryFont
                              ),
                              textAlign: TextAlign.right),
                          onPressed: () async {
                            setState(() {
                              FirebaseFirestore.instance.collection("voucher").doc(voucherId).collection('order').get().then((snapshot) {
                                for (DocumentSnapshot doc in snapshot.docs) {
                                  doc.reference.delete();
                                }
                                print("delete");
                              });
                                FirestoreService().remove("voucher", voucherId);
                                NotiService().sendNoti('Order Cancel Alert','$userName မှ အော်ဒါ cancel ဖြစ်သွားသည်' );

                                //TODO:to add the admin noti count
                              //
                              // FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
                              //   int notiCount=int.parse(document.data()['message_noti'].toString());
                              //   print("notiCOunt"+notiCount.toString());
                              //   FirebaseFirestore.instance.collection('user').doc(userId)
                              //       .update({'message_noti': ++notiCount})
                              //       .then((value) => print("message noti  User Updated"))
                              //       .catchError((error) => print("Failed to update user: $error"));
                              // });

                              NotiModel notiModel= NotiModel(
                                notiId: uuid.v4(),
                                notiTitle: "အမှာစာ ပယ်ဖျက်ခြင်း",
                                notiText: "$userName မှ အမှာစာ ပယ်ဖျက်လိုက်ပါသည် (Voucher Number=${ convertVoucher(voucherNumber.toString()) })",
                                notiType: 'unread',
                                createdDate: DateTime.now().millisecondsSinceEpoch,
                                sender: userId,
                                photo: userPhoto,
                              );
                              FirestoreService().addNoti(notiModel);

                                Fluttertoast.showToast(msg: "အော်ဒါ cancel ဖြစ်သွားသည်" ,toastLength: Toast.LENGTH_LONG,backgroundColor: Constants.thirdColor);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => VoucherPage()),
                                );

                            });
                            Fluttertoast.showToast(msg: "ဖျက်ပြီးပါပြီ" ,toastLength: Toast.LENGTH_LONG,backgroundColor: Constants.thirdColor);
                          },
                        ),
                        FlatButton(
                          child: Text('မဖျက်ပါ ',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Constants.primaryColor,
                                  fontFamily: Constants.PrimaryFont
                              ),
                              textAlign: TextAlign.right),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  );
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
                    child: Text('အော်ဒါကို ဖျက်မည်',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
