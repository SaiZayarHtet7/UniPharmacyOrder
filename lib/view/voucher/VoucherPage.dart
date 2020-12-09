import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/service/firebase_storage.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/HomePage.dart';
import 'package:uni_pharmacy_order/view/LoginPage.dart';
import 'package:uni_pharmacy_order/view/PriceList/PricePage.dart';
import 'package:uni_pharmacy_order/view/chat/ChatBox.dart';
import 'package:uni_pharmacy_order/view/contact/ContactPage.dart';
import 'package:uni_pharmacy_order/view/notification/NotificationPage.dart';
import 'package:uni_pharmacy_order/view/order/OrderPage.dart';
import 'package:uni_pharmacy_order/view/product/ProductPage.dart';
import 'package:uni_pharmacy_order/view/voucher/VoucherOrder.dart';
import 'package:uni_pharmacy_order/widget/NotiIcon.dart';
import 'package:uni_pharmacy_order/widget/TitleTextColor.dart';
import 'package:uni_pharmacy_order/widget/VoucherCard.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  ///Declaration
  bool loading;
  String userId,userName,notiCountStr,messageNoti;
  int current = 0;
  List<String> imgList = [];
  int prepareOrderCount,deliverOrderCount;


  Future<bool> _onWillPop() async {
    print('Voucher Page Back');

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
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = pref.getString("user_name");
      userId= pref.getString('uid');
      print(userName);
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
    FirebaseFirestore.instance.collection("voucher").where('user_name',isEqualTo: userName).where('status',isEqualTo: Constants.orderPrepare).get().then((value){
      setState(() {
        prepareOrderCount = value.docs.length;
      });
      print('number of prepare order'+prepareOrderCount.toString());
    });

    FirebaseFirestore.instance.collection("voucher").where('user_name',isEqualTo: userName).where('status',isEqualTo: Constants.orderDeliver).get().then((value){
      setState(() {
        deliverOrderCount = value.docs.length;
      });
      print('number of deliver order'+deliverOrderCount.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
            key: _scaffoldKey,

            endDrawer: new Drawer(child: HeaderOnly()),
            appBar: AppBar(
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
              automaticallyImplyLeading: false,
              titleSpacing: 0,
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
                      child: Text('ဘောက်ချာများ',style: TextStyle(color: Constants.primaryColor,fontSize: 18,),)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                          onTap: (){
                            ///Logics for notification
                            FirebaseFirestore.instance.collection('user').doc(userId)
                                .update({'noti_count': 0})
                                .then((value) => print("User Updated"))
                                .catchError((error) => print("Failed to update user: $error"));
                            setState(() {
                              notiCountStr="0";
                            });
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
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                  Container(
                    width:MediaQuery.of(context).size.width,
                      child: TitleTextColor(Constants.orderPrepare,Constants.thirdColor)),
                  Container(
              height: 60,
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width:75,
                        child: Text('ရက်စွဲ',textAlign: TextAlign.center,style: TextStyle(fontFamily: Constants.PrimaryFont),)),
                    Text('ဘောက်ချာအမှတ်',style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont),),
                    Container(
                        width: 130,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ],
              ),
            ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('voucher').where("user_name",isEqualTo: userName).where("status",isEqualTo: Constants.orderPrepare).orderBy('voucher_number').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if(snapshot.hasData){
                          return ListView(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: snapshot.data.documents.map((DocumentSnapshot document) {
                              return InkWell(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => VoucherOrder(document.data()['voucher_id'],document.data()['voucher_number'].toString())),
                                  );
                                },
                                  child: VoucherCard(document.data()['date_time'], document.data()['voucher_number'].toString(), document.data()['status']));
                            }).toList(),
                          );
                        }else{
                          return TitleTextColor("No data", Constants.thirdColor);
                        }
                      }),
                    ],
                  ),
                ),
                prepareOrderCount==0 || prepareOrderCount==null ? Center(child: SizedBox(child: Text('ပြင်ဆင်နေစဲ အော်ဒါမရှိသေးပါ',style: TextStyle(color: Constants.thirdColor,fontFamily: Constants.PrimaryFont,fontSize: 16),),)):SizedBox(),
                Divider(color: Colors.black,),
                Column(
                  children: [
                    Container(
                        width:MediaQuery.of(context).size.width,
                        child: TitleTextColor('ပစ္စည်းပို့ပြီး',Constants.primaryColor)),
                    Container(
                      height: 60,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              width:75,
                              child: Text('ရက်စွဲ',textAlign: TextAlign.center,style: TextStyle(fontFamily: Constants.PrimaryFont),)),
                          Text('ဘောက်ချာအမှတ်',style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont),),
                          Container(
                            width: 120,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('voucher').where("user_name",isEqualTo: userName).where("status",isEqualTo: Constants.orderDeliver).orderBy('voucher_number').snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if(snapshot.hasData){
                            return ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              reverse: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: snapshot.data.documents.map((DocumentSnapshot document) {
                                return InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => VoucherOrder(document.data()['voucher_id'],document.data()['voucher_number'].toString())),
                                    );
                                  },
                                    child: VoucherCard(document.data()['date_time'], document.data()['voucher_number'].toString(), document.data()['status']));
                              }).toList(),
                            );
                          }else{
                            return TitleTextColor("No data", Constants.thirdColor);
                          }
                        }),
                    deliverOrderCount==0 || deliverOrderCount==null ? Center(child: SizedBox(child: Text('ဘောက်ချာ မရှိသေးပါ',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 16),),)):SizedBox(),
                  ],
                ),

              ],
            ),
          ),
        )
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
      child: messageNoti==null? Center(child: CircularProgressIndicator()): ListView(children: <Widget>[
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
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/order.png')),
          title: Text(
            "အ‌ဝယ်စာရင်း",
            style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderPage()));
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
        ///vouchers
        Container(
          color: Constants.thirdColorAccent,
          child: ListTile(
            leading: Container(
                padding: EdgeInsets.all(5.0),
                child: ClipOval(child: Image.asset('assets/image/voucher.png'))),
            title: Text(
              "အ‌ဝယ်ဘောက်ချာများ",
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
    File  tmpFile = File(picture.path);
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