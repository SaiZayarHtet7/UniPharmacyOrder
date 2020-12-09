import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/model/NotiModel.dart';
import 'package:uni_pharmacy_order/service/NotiService.dart';
import 'package:uni_pharmacy_order/service/firebase_storage.dart';
import 'package:uni_pharmacy_order/service/firestore_service.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/HomePage.dart';
import 'package:uni_pharmacy_order/view/LoginPage.dart';
import 'package:uni_pharmacy_order/view/PriceList/PricePage.dart';
import 'package:uni_pharmacy_order/view/chat/ChatBox.dart';
import 'package:uni_pharmacy_order/view/contact/ContactPage.dart';
import 'package:uni_pharmacy_order/view/notification/NotificationPage.dart';
import 'package:uni_pharmacy_order/view/product/ProductOrder.dart';
import 'package:uni_pharmacy_order/view/product/ProductPage.dart';
import 'package:uni_pharmacy_order/view/voucher/VoucherPage.dart';
import 'package:uni_pharmacy_order/widget/NotiIcon.dart';
import 'package:uni_pharmacy_order/widget/TextData.dart';
import 'package:uni_pharmacy_order/widget/TextDataColor.dart';
import 'package:uni_pharmacy_order/widget/TitleTextColor.dart';
import 'package:http/http.dart' as httpLib;
import 'package:intl/intl.dart';
import 'package:uni_pharmacy_order/model/VoucherModel.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {

  String userName,userId,userPhoto;
  final ScrollController scrollController = ScrollController();
  int orderCount;
  List<String> tokenList=[];
  int unitCount;
  bool isLoading;
  var uuid=Uuid();
  String userToken,notiCountStr,messageNoti;
  AutoScrollController controller;
  int voucherCount;
  double totalCost;
  List<int> voucherArr=[0];
  String convertVoucher(String vNo){
    do{
      vNo="0"+vNo;
    }while(vNo.length<5);
    return  vNo;
  }
  Future<bool> _onWillPop() async {
    print('OrderPage BackButton');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage(),
      ),
          (route) => false,
    );

    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text( 'Application မှထွက်ရန် သေချာပြီလား?',
    //         style: new TextStyle(
    //             fontSize: 20.0, color: Constants.thirdColor,fontFamily: Constants.PrimaryFont)),
    //     actions: <Widget>[
    //       FlatButton(
    //         child: Text('ထွက်မည်',
    //             style: new TextStyle(
    //                 fontSize: 16.0,
    //                 color: Constants.primaryColor,
    //                 fontFamily: Constants.PrimaryFont
    //             ),
    //             textAlign: TextAlign.right),
    //         onPressed: () async {
    //           SystemNavigator.pop();
    //         },
    //       ),
    //       FlatButton(
    //         child: Text('မထွက်ပါ',
    //             style: new TextStyle(
    //                 fontSize: 16.0,
    //                 color: Constants.primaryColor,
    //                 fontFamily: Constants.PrimaryFont
    //             ),
    //             textAlign: TextAlign.right),
    //         onPressed: () {
    //           Navigator.pop(context);
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

  fetchData() async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    setState(() {
      userName=pref.getString("user_name");
      userId=pref.getString("uid");
      userToken=pref.getString("token");
      userPhoto=pref.getString('user_photo');
    });
    FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
      int notiCount=int.parse(document.data()['noti_count'].toString());
      print("notiCOunt"+notiCount.toString());
      setState(() {
        notiCountStr=notiCount.toString();
      });
    });
    FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
      int notiCount=int.parse(document.data()['message_noti'].toString());
      print("notiCOunt"+notiCount.toString());
      setState(() {
        messageNoti=notiCount.toString();
      });
    });
    FirebaseFirestore.instance.collection("user").doc(userId).collection('order').get().then((value){
      orderCount = value.docs.length;
      print('number of order'+orderCount.toString());
    });

    totalCost=0.0;
    print(userId);
    FirebaseFirestore.instance.collection("user").doc(userId).collection("order").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          totalCost =totalCost+double.parse(result.data()['cost']);
        });
      });
    });
    print("The total is $totalCost");
  }


  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      Firebase.initializeApp();
      isLoading=false;
    });
    fetchData();
    super.initState();
  }

   getTotal(String user) async {
    totalCost=0.0;
    print('userId'+user);
    FirebaseFirestore.instance.collection("user").doc(user).collection("order").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          totalCost =totalCost+double.parse(result.data()['cost']);
        });
      });
    });
    print("The total is $totalCost");
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          endDrawer:new Drawer(
              child: HeaderOnly()),
          appBar:  AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            actions: [
              InkWell(child:messageNoti=="0"||messageNoti==null ?
              Image.asset('assets/image/menu.png',width: 30,):
              Badge(position:BadgePosition(top: 4,end: -5) ,
                badgeContent: Text(messageNoti.toString()),child:Image.asset('assets/image/menu.png',width: 30,) , ),onTap: (){
                ///Logics for notification
                _scaffoldKey.currentState.openEndDrawer();
              },),
              SizedBox(width: 10.0,)
            ],
            iconTheme: new IconThemeData(color: Constants.primaryColor),
            toolbarHeight: 70,
            backgroundColor: Colors.white,
            // Don't show the leading button
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/image/logo.png',width: 95,),
                Container(width: 130.0,
                    padding: EdgeInsets.only(left: 10),
                    child: Text('အဝယ်စာရင်း',style: TextStyle(color: Constants.primaryColor,fontSize: 18,),)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                        onTap: (){
                          ///Logics for notification
                          FirebaseFirestore.instance.collection('user').doc(userId)
                              .update({'noti_count': 0})
                              .then((value) => print("User Updated"))
                              .catchError((error) => print("Failed to update user: $error"));
                          notiCountStr="0";
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationPage()));
                        },
                        child: NotiIcon(context,userId,notiCountStr)),
                    SizedBox(width: 10,),
                  ],),
              ],
            ),
          ),
          body: SingleChildScrollView (
            child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       controller: scrollController,
                       child: Padding(
                         padding: const EdgeInsets.only(left: 10,right: 10,top: 20,bottom: 20),
                         child: Scrollbar(
                           controller: scrollController,
                           isAlwaysShown: true,

                           child: StreamBuilder<QuerySnapshot>(
                               stream: FirebaseFirestore.instance.collection('user').doc(userId).collection("order").snapshots(),
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
                                         DataColumn(label: Expanded(child: Align(alignment:Alignment.centerRight, child: Text("သင့်ငွေ",textAlign: TextAlign.center,style: TextStyle(color: Constants.thirdColor,fontSize: 13,fontFamily: Constants.PrimaryFont))))),
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
                                                      child: Container(padding:EdgeInsets.only(left: 10),child: Text(Constants().oCcy.format(double.parse(data.data()['cost'])).toString() + ".00", style: TextStyle(color: Constants.primaryColor, fontFamily: Constants.PrimaryFont, fontSize: 14),)))),
                                                  DataCell(ClipOval(
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
                                                            MaterialPageRoute(builder: (context) => ProductOrder("order","","",data.data()['product_id'],data.data()['product_name'],data.data()['product_image'],data.data()['order_id'],data.data()['quantity'],data.data()['unit'],data.data()['cost'])),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )),
                                                  DataCell(ClipOval(child: Material(
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
                                                          setState(() {
                                                            totalCost=totalCost- double.parse (  data.data()['cost']);
                                                            --orderCount;
                                                          });
                                                          FirestoreService().removeOrder("order", userId, data.data()['order_id']);
                                                          Fluttertoast.showToast(msg: "ဖျက်ပြီးပါပြီ" ,toastLength: Toast.LENGTH_SHORT,backgroundColor: Constants.thirdColor);
                                                        },
                                                      ),
                                                    ),
                                                  ))
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

                    orderCount==0 || orderCount==null ? Center(child: SizedBox(child: Text('အဝယ်စာရင်း မရှိသေးပါ',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 16),),)):
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

                     orderCount==0 || orderCount==null ? SizedBox( ):  isLoading==true? Container(margin: EdgeInsets.all(10),
                    width: 50.0,
                    height: 50.0,child: CircularProgressIndicator(backgroundColor: Constants.thirdColor,),):
                    Container(
                       margin: EdgeInsets.all(10),
                       height: 50.0,
                       child: RaisedButton(
                         onPressed: () async {

                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               title: Text( 'မှာယူရန် သေချာပြီလား',
                                   style: new TextStyle(
                                       fontSize: 20.0, color: Constants.thirdColor,fontFamily: Constants.PrimaryFont)),
                               actions: <Widget>[
                                 FlatButton(
                                   child: Text('မှာယူမည်',
                                       style: new TextStyle(
                                           fontSize: 16.0,
                                           color: Constants.primaryColor,
                                           fontFamily: Constants.PrimaryFont
                                       ),
                                       textAlign: TextAlign.right),
                                   onPressed: () async {

                                     setState(() {
                                       isLoading=true;
                                     });
                                     final DateTime now = DateTime.now();

                                     DateFormat dateFormat = new DateFormat('dd-MM-yyyy hh:mm a');
                                     print(dateFormat.format(now));
                                     String voucherId=uuid.v4();

                                     FirebaseFirestore.instance.collection("voucher").get().then((value){
                                       value.docs.forEach((element) {
                                         voucherArr.add(element.data()['voucher_number']);
                                       });
                                       voucherArr.sort();
                                       print(voucherArr.last);
                                       int voucherNumber=voucherArr.last;
                                       VoucherModel voucherModel =VoucherModel(
                                         searchName: Constants().setSearchParam(userName.toLowerCase()),
                                         voucherId:voucherId,
                                         userName: userName,
                                         token:userToken,
                                         dateTime: dateFormat.format(now).toString(),
                                         status:Constants.orderPrepare,
                                         userId: userId,
                                         voucherNumber:(voucherNumber == null || voucherNumber == 0) ? 1: (voucherNumber+1),
                                       );
                                       FirestoreService().addVoucher("voucher",voucherModel );

                                       NotiModel notiModel= NotiModel(
                                         notiId: uuid.v4(),
                                         notiTitle: "အမှာစာအသစ်",
                                         notiText: "$userName ထံမှ အော်ဒါလက်ခံရရှိပါသည် (Voucher Number=${ convertVoucher((++voucherNumber).toString()) })",
                                         notiType: 'unread',
                                         createdDate: DateTime.now().millisecondsSinceEpoch,
                                         sender: userId,
                                         photo: userPhoto,
                                       );
                                       FirestoreService().addNoti(notiModel);
                                     });

                                     ///copying data from order to voucher
                                     FirebaseFirestore.instance.collection("user").doc(userId).collection("order").get().then((querySnapshot) {
                                       querySnapshot.docs.forEach((result) {
                                         FirebaseFirestore.instance.collection('voucher')
                                             .doc(voucherId).collection('order').doc(result.data()['order_id'])
                                             .set(result.data());
                                         print(result.data);
                                       });
                                     });

                                     FirebaseFirestore.instance.collection('user').doc(userId).collection('order').get().then((snapshot) {
                                       for (DocumentSnapshot doc in snapshot.docs) {
                                         doc.reference.delete();
                                       }
                                       print("delete");
                                     });
                                     NotiService().sendNoti("အမှာစာ အသစ်" ,"$userName ထံမှအော်ဒါ လက်ခံရရှိပါသည်");
                                     setState(() {
                                       isLoading=false;
                                     });
                                     Navigator.of(context).pop();
                                     setState(() {
                                       totalCost=0.0;
                                       orderCount=0;
                                     });
                                     Fluttertoast.showToast(msg: "မှာယူမူအတွက်  အထူးကျေးဇူးတင်ရှိပါသည်" ,toastLength: Toast.LENGTH_LONG,backgroundColor: Constants.thirdColor);
                                   },
                                 ),
                                 FlatButton(
                                   child: Text('မမှာယူပါ',
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
                             child: Text('မှာယူမည်',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                           ),
                         ),
                       ),
                     ),
                     SizedBox(height: 10.0,),
                     orderCount==0 || orderCount==null ? SizedBox( ):  isLoading==true? Container(margin: EdgeInsets.all(10),
                       width: 50.0,
                       height: 50.0,child: CircularProgressIndicator(backgroundColor: Constants.thirdColor,),):
                     Container(
                       padding: EdgeInsets.symmetric(horizontal:10),
                       child: RaisedButton(
                         onPressed: (){
                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               title: Text( 'အဝယ်စာရင်းကိုဖျက်ရန် သေချာပြီလား?',
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
                                       isLoading=true;
                                     });
                                     FirebaseFirestore.instance.collection('user').doc(userId).collection('order').get().then((snapshot) {
                                       for (DocumentSnapshot doc in snapshot.docs) {
                                         doc.reference.delete();
                                       }
                                       Navigator.of(context).pop();
                                       setState(() {
                                         orderCount=0;
                                         isLoading=false;
                                       });

                                       print("delete");
                                     });
                                   },
                                 ),
                                 FlatButton(
                                   child: Text('မဖျက်ပါ',
                                       style: new TextStyle(
                                         color: Constants.primaryColor,
                                         fontFamily: Constants.PrimaryFont,
                                         fontSize: 16.0,
                                       ),
                                       textAlign: TextAlign.right),
                                   onPressed: () {
                                     Navigator.of(context).pop();
                                   },
                                 )
                               ],
                             ),
                           );

                         },
                         padding: EdgeInsets.all(0.0),
                         child: Ink(
                           decoration: BoxDecoration(color: Colors.white),
                           child: Container(
                             constraints: BoxConstraints(minHeight: 50.0),
                             alignment: Alignment.center,
                             child: Text('အဝယ်စာရင်းကို ပယ်ဖျက်မည်', style: TextStyle(color: Constants.primaryColor,fontSize: 18.0,fontFamily:Constants.PrimaryFont),
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
                     ),

                   ],
                 ),
              ],
            ),),
          ),
        ),
      ),
    );
  }
}

class HeaderOnly extends StatefulWidget {
  @override
  _HeaderOnlyState createState() => _HeaderOnlyState();
}

class _HeaderOnlyState extends State<HeaderOnly> {
  String userName;
  String userPhoto;
  String phoneNumber;
  String address;
  String userId,messageNoti;
  bool loading;
  final picker = ImagePicker();
  File userImage;

  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    loading=true;
    super.initState();
  }

  fetchData() async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    userName= pref.getString('user_name');
    userPhoto= pref.getString('user_photo');
    phoneNumber= pref.getString('phone_number');
    address= pref.getString('address');
    userId= pref.getString('uid');

    FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
      int notiCount=int.parse(document.data()['message_noti'].toString());
      print("notiCOunt"+notiCount.toString());
      setState(() {
        messageNoti=notiCount.toString();
      });
    });

    setState(() {
      loading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:messageNoti==null? Center(child: CircularProgressIndicator()):   ListView(children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
              color: Constants.primaryColor
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              loading==true? Center(child: CircularProgressIndicator()):
              InkWell(onTap: (){
                _onButtonPressed_for_image(context);
              },
                child: userPhoto=="" ?  Container(
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                  ),
                  child: Center(child: Text("ပုံထည့်မည်",style: TextStyle(fontFamily: Constants.PrimaryFont),)),
                ): CachedNetworkImage(
                  imageUrl:userPhoto,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ) ,
              ),
              SizedBox(height: 10.0,),
              Text(userName,style: TextStyle(color:Colors.white,fontSize: 14,fontFamily: Constants.PrimaryFont),)
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text("Menu",style: TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 16,fontWeight: FontWeight.bold),)),
        SizedBox(height: 10.0,),
        ///home
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/circular_home.png')),
          title: Text(
            "ပင်မစာမျက်နှာ",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///product
        ListTile(
          leading: Container(
            padding: EdgeInsets.all(5.0),
            child: ClipOval(
              child:  Image.asset('assets/image/product.png'),
            ),
          ),
          title: Text(
            "ကုန်ပစ္စည်း",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///price
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/price_list.png')),
          title: Text(
            "စျေးနူန်းစာရင်း",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PricePage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///order
        Container(
          color: Constants.thirdColorAccent,
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: ClipOval(child: Image.asset('assets/image/order.png'))),
            title: Text(
              "အ‌ဝယ်စာရင်း",
              style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///vouchers
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/voucher.png')),
          title: Text(
            "အ‌ဝယ်ဘောက်ချာများ",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => VoucherPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ///chat
        messageNoti=="0"? ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/message.png')),
          title: Text(
            "ရောင်းသူနှင့် စကားပြောရန်",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatBox()));
          },
        ) :Badge(
          position: BadgePosition(top: -5,end: 30),
          badgeContent: Text(messageNoti),
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: Image.asset('assets/image/message.png')),
            title: Text(
              "ရောင်းသူနှင့် စကားပြောရန်",
              style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
            ),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatBox()));
              //TODO
              FirebaseFirestore.instance.collection('user').doc(userId)
                  .update({'message_noti':0})
                  .then((value) => print("User Updated"))
                  .catchError((error) => print("Failed to update user: $error"));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),

        SizedBox(height: 30.0,),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text("General",style: TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 16,fontWeight: FontWeight.bold),)),
        SizedBox(height: 10.0,),
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/contact.png')),
          title: Text(
            "ဆက်သွယ်ရန်",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/smartphone.png')),
          title: Text(
            "အကောင့်မှထွက်ရန်",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0,color: Constants.primaryColor),
          ),
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text( 'Account မှထွက်ရန် သေချာပြီလား?',
                    style: new TextStyle(
                        fontSize: 20.0, color: Constants.thirdColor,fontFamily: Constants.PrimaryFont)),
                actions: <Widget>[
                  FlatButton(
                    child: Text('ထွက်မည်',
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: Constants.primaryColor,
                            fontFamily: Constants.PrimaryFont
                        ),
                        textAlign: TextAlign.right),
                    onPressed: () async {
                      SharedPreferences pref= await SharedPreferences .getInstance();
                      await FirebaseAuth.instance.signOut();
                      FirebaseAuth.instance
                          .authStateChanges()
                          .listen((User user) {
                        if (user == null) {
                          print('User is currently signed out!');
                          pref.clear();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        } else {
                          print('User is signed in!');
                        }
                      });
                    },
                  ),
                  FlatButton(
                    child: Text('မထွက်ပါ',
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
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => HomePage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0,right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),
      ]),
    );
  }

  void _onButtonPressed_for_image(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text( 'ပုံအသစ်ယူပါ'),
                      onTap: () {
                        _openCamera(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('ပုံအသစ်ရွေးပါ'),
                      onTap: () {
                        _openGallary(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.cancel),
                      title: Text('ပယ်ဖျက်ပါ'),
                      onTap: () => Navigator.pop(context),
                    )
                  ],
                ),

              ],
            ),
          );
        });
  }

  Future _openGallary(BuildContext context) async {

    SharedPreferences pref=await SharedPreferences.getInstance();
    var picture = await picker.getImage(source: ImageSource.gallery);
    File tmpFile = File(picture.path);
    userImage = tmpFile;
    Navigator.pop(context);
    setState(() {
      loading=true;
    });

    CollectionReference users = FirebaseFirestore.instance.collection('user');
    if(userPhoto == "" ) {
      userPhoto = await FirebaseStorageService().UploadPhoto('user', userImage);
      pref.setString('user_photo', userPhoto);
      users
          .doc(userId)
          .update({'profile_image': userPhoto})
          .then((value) {
        print("User Updated");
      });

    }else{
      var newImage=await FirebaseStorageService().EditPhoto(userPhoto, 'user', userImage);
      userPhoto=newImage.toString();
      pref.setString('user_photo', userPhoto);
      users
          .doc(userId)
          .update({'profile_image': userPhoto})
          .then((value) {
        print("User Updated");
      });
    }
    setState(() {
      loading=false;
    });
  }


  Future _openCamera(BuildContext context) async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    final picture = await picker.getImage(source: ImageSource.camera);
    File tmpFile = File(picture.path);
    userImage = tmpFile;
    Navigator.pop(context);
    setState(() {
      loading=true;
    });
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    if(userPhoto == "" ) {
      userPhoto = await FirebaseStorageService().UploadPhoto('user', userImage);
      pref.setString('user_photo', userPhoto);
      users
          .doc(userId)
          .update({'profile_image': userPhoto})
          .then((value) {
        print("User Updated");
      });

    }else{
      var newImage=await FirebaseStorageService().EditPhoto(userPhoto, 'user', userImage);
      userPhoto=newImage.toString();
      pref.setString('user_photo', userPhoto);
      users
          .doc(userId)
          .update({'profile_image': userPhoto})
          .then((value) {
        print("User Updated");
      });
    }
    setState(() {
      loading=false;
    });
  }
}
