import 'dart:io';
import 'package:badges/badges.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/providers/Connectivity.dart';
import 'package:uni_pharmacy_order/service/firebase_storage.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/LoginPage.dart';
import 'package:uni_pharmacy_order/view/PriceList/PricePage.dart';
import 'package:uni_pharmacy_order/view/chat/ChatBox.dart';
import 'package:uni_pharmacy_order/view/contact/ContactPage.dart';
import 'package:uni_pharmacy_order/view/notification/NotificationPage.dart';
import 'package:uni_pharmacy_order/view/order/OrderPage.dart';
import 'package:uni_pharmacy_order/view/product/ProductPage.dart';
import 'package:uni_pharmacy_order/view/voucher/VoucherPage.dart';
import 'package:uni_pharmacy_order/widget/NotiIcon.dart';

var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    ///Declaration
    bool loading;
    String userName,userId,notiCountStr,messageNoti;
    CarouselController buttonCarouselController = CarouselController();
    int current=0;
    final ScrollController scrollController = ScrollController();
    List<String> imgList = [];
    var format =new DateFormat('dd-MM-yyyy hh:mm a');
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    int secondInDate=86400000;
    int threeDaysAgo;
    int updatedPristCount;
    
    Future<bool> _onWillPop() async {
      print('hellp');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text( 'Application မှထွက်ရန် သေချာပြီလား?',
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
                SystemNavigator.pop();
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
    }

  fetchData() async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    userName=pref.getString("user_name");
    userId=pref.getString('uid');
    FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
      int notiCount=int.parse(document.data()['noti_count'].toString());
      print("notiCOunt"+notiCount.toString());
      notiCountStr=notiCount.toString();
    });




    FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
      int notiCount=int.parse(document.data()['message_noti'].toString());
      print("notiCOunt"+notiCount.toString());
      setState(() {
        messageNoti=notiCount.toString();
      });
    });

    threeDaysAgo=DateTime.now().millisecondsSinceEpoch-(secondInDate*3);

    FirebaseFirestore.instance.collection('updatedPrice').where('created_date',isGreaterThanOrEqualTo: threeDaysAgo).get().then((value){
      updatedPristCount= value.docs.length;
      print('number of updated PriceCount '+updatedPristCount.toString());
    });


    
    FirebaseFirestore.instance.collection("slide").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        imgList.add(result.data()['slide'].toString());
        print(imgList);
      });
      setState(() {
        loading=false;
      });
    });
  }

    showNotification(Map<String, dynamic> msg) async {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,);
      var androidChannelSpecifics = AndroidNotificationDetails(
          'default',
        msg["notification"]["title"].toString(),
        msg["notification"]["body"].toString(),);
      var iOSChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidChannelSpecifics, iOSChannelSpecifics);
      FlutterLocalNotificationsPlugin localNotifPlugin =
      new FlutterLocalNotificationsPlugin();
      var android = new AndroidNotificationDetails(
          'id', 'channel ', 'description',
          playSound: true,
          sound: RawResourceAndroidNotificationSound('noti_sound'),
          showWhen: true,
          priority: Priority.High, importance: Importance.Max);
      var iOS = new IOSNotificationDetails();
      var platform = new NotificationDetails(android, iOS);
      await flutterLocalNotificationsPlugin.show(
          1, msg["notification"]["title"].toString(),msg["notification"]["body"].toString() , platform);
      await localNotifPlugin.show(
          1,
          msg["notification"]["title"].toString(),
          msg["notification"]["body"].toString(),
          platformChannelSpecifics
          );
    }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      Firebase.initializeApp();
      FirebaseFirestore.instance.settings =
          Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    });

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          print("onMessage: $message");
          fetchData();
        });
        showNotification(message);

        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ProductPage()));

      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ProductPage()));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");


      },
    );
    loading=true;
    fetchData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:WillPopScope(
        onWillPop: _onWillPop,
        child: MultiProvider(
          providers: [
            Provider<NetworkProvider>(
              create: (context) => NetworkProvider(),
              dispose: (context, service) => service.disposeStreams(),
            )
          ],
          child: Scaffold(
            key: _scaffoldKey,
            endDrawer:new Drawer(
                child: HeaderOnly()),
            appBar: AppBar(
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
                  userName==null? Container(padding: EdgeInsets.only(left: 10),child: CircularProgressIndicator()):  Container(width: 100.0,
                    padding: EdgeInsets.only(left: 10),
                    child:  Text('$userName',style: TextStyle(color: Colors.black,fontSize: 14),)),
                  Image.asset('assets/image/logo.png',width: 95,),
                  Row(children: [
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
                    SizedBox(width: 10.0,)
                  ],)
                ],
              ),
            ),
            body: SafeArea(
              child: Consumer<NetworkProvider>(
                  builder: (context,networkProvider,child){
                    return StreamProvider<ConnectivityResult>.value(value: networkProvider.networkStatusController.stream,
                      child: Consumer<ConnectivityResult>(
                        builder: (context,value,_){
                          if(value==null) {
                            return Container(
                              width: double.infinity, height: double.infinity,
                              child: Center(
                                child: Text('Error in Connectivity result'),),);
                          }
                          return value==ConnectivityResult.none ? Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(child: Image.asset('assets/image/logo.jpg',width: MediaQuery.of(context).size.width/2,)),
                                Lottie.asset('assets/anim/offline_anim.json',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Text('Please connect Mobile Internet or Wifi\n to use Application',textAlign: TextAlign.center,style: TextStyle(fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                                SizedBox(height: 60.0,),
                              ],
                            ),
                          ):
                          Container(
                            color: Constants.thirdColor,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                loading ==true? Center(child: CircularProgressIndicator()):
                                CarouselSlider(
                                  items: imgList.map((item) => Container(
                                    color: Colors.white,
                                    child: Center(
                                      child: CachedNetworkImage(
                                        imageUrl:item,
                                        fit: BoxFit.cover,height: MediaQuery.of(context).size.height/1.8,
                                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                                            Container(padding: EdgeInsets.all(133),height: 50.0,
                                                child: CircularProgressIndicator( value: downloadProgress.progress)),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    ),
                                  )).toList(),
                                  carouselController: buttonCarouselController,
                                  options: CarouselOptions(
                                      onPageChanged: (index,reason){
                                        setState(() {
                                          current=index;
                                        });
                                      },
                                      autoPlay: true,
                                      height: 300,
                                      enlargeCenterPage: false,
                                      viewportFraction: 1,
                                      aspectRatio: 1.5,
                                      initialPage: 0,
                                      scrollDirection: Axis.horizontal
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: imgList.map((url) {
                                    int index = imgList.indexOf(url);
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: current == index
                                            ? Color.fromRGBO(0, 0, 0, 1)
                                            : Color.fromRGBO(0, 0, 0, 0.4),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                Container(
                                  width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Text(updatedPristCount==0?'စျေးနူန်း အပြောင်းအလဲများ မရှိသေးပါ': 'စျေးနူန်း အပြောင်းအလဲများ',style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont),)),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  height: MediaQuery.of(context).size.height/2.55,
                                  child:
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('updatedPrice').where('created_date',isGreaterThanOrEqualTo: threeDaysAgo).orderBy('created_date',descending: true).snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      return new ListView(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: false,
                                        children: snapshot.data.docs.map((DocumentSnapshot document) {
                                          return new Card(
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl:document.data()['product_photo'],
                                                    fit: BoxFit.cover,
                                                    imageBuilder: (context, imageProvider) => Container(
                                                      width:50.0,
                                                      height: 50.0,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Constants.thirdColor,width: 1),
                                                        borderRadius: BorderRadius.circular(10),
                                                        image: DecorationImage(
                                                            image: imageProvider, fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                    placeholder: (context, url) => CircularProgressIndicator(),
                                                    errorWidget: (context, url, error) => Icon(Icons.pages_rounded,color: Constants.primaryColor,size: 50,),
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width/1.5,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                      Text(document.data()['product_name']+" ( "+document.data()['quantity'].toString()+' '+document.data()['unit'] +" စျေး )" ,style: TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 15), ),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        mainAxisSize: MainAxisSize.max,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text('ယခင်စျေး',style: TextStyle(color: Constants.primaryColor,fontSize: 15,fontFamily: Constants.PrimaryFont),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(document.data()['old_price'],style: TextStyle(decoration: TextDecoration.lineThrough,color: Constants.thirdColor),),Text(' ကျပ်',style: TextStyle(),)
                                                                ],)
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text('ယခုစျေး',style: TextStyle(color: Constants.primaryColor,fontSize: 15,fontFamily: Constants.PrimaryFont),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(document.data()['new_price'],style: TextStyle(color: Constants.thirdColor),),Text(' ကျပ်',style: TextStyle(),)
                                                                ],)
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Expanded(
                                                        flex: 0,
                                                        child: Align(
                                                          alignment: Alignment.bottomRight,
                                                          child: Text(format.format(DateTime.fromMicrosecondsSinceEpoch(int.parse(document.data()['created_date'].toString())*1000)).toString().substring(0,10),
                                                            style: TextStyle(color: Colors.grey,fontSize:13),),
                                                        ),
                                                      ),
                                                    ],),
                                                  ),

                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),

                                  // Column(
                                  //   children: [
                                  //     Divider(height: 2,color: Colors.white,),
                                  //     SizedBox(height: 10.0,),
                                  //     Container(width: MediaQuery.of(context).size.width,
                                  //         child: Text('Updates',style: TextStyle(color: Colors.white,fontSize: 18,fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),)),
                                  //     SizedBox(height: 10.0,),
                                  //     Card(color: Colors.white,
                                  //       elevation: 3,
                                  //       child: Container(
                                  //         padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  //         width: MediaQuery.of(context).size.width,
                                  //         height: 100.0,
                                  //         child: Column(
                                  //           children: [
                                  //             Container(width: double.infinity,
                                  //                 child: Text('လက်ကားစျေး',style: TextStyle(color: Constants.primaryColor,fontSize: 14,fontFamily: Constants.PrimaryFont),)),
                                  //               Divider(height: 2,color: Constants.thirdColor,),
                                  //             SizedBox(height: 15.0,),
                                  //             Row(
                                  //               children: [
                                  //                 Text('10',style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont,fontSize: 14),),
                                  //                 Text('ဗူး',style:TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont,fontSize: 14) ,)
                                  //               ],
                                  //             )
                                  //           ],
                                  //     ),
                                  //       ),),
                                  //     Card(color: Colors.white,
                                  //       elevation: 3,
                                  //       child: Container(
                                  //         padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  //         width: MediaQuery.of(context).size.width,
                                  //         height: 100.0,
                                  //         child: Column(
                                  //           children: [
                                  //             Container(width: double.infinity,
                                  //                 child: Text('လက်ကားစျေး',style: TextStyle(color: Constants.primaryColor,fontSize: 14,fontFamily: Constants.PrimaryFont),)),
                                  //             Divider(height: 2,color: Constants.thirdColor,),
                                  //             SizedBox(height: 15.0,),
                                  //             Row(
                                  //               children: [
                                  //                 Text('10',style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont,fontSize: 14),),
                                  //               ],
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),),
                                  //     Card(color: Colors.white,
                                  //       elevation: 3,
                                  //       child: Container(
                                  //         padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                  //         width: MediaQuery.of(context).size.width,
                                  //         height: 100.0,
                                  //         child: Column(
                                  //           children: [
                                  //             Container(width: double.infinity,
                                  //                 child: Text('လက်ကားစျေး',style: TextStyle(color: Constants.primaryColor,fontSize: 14,fontFamily: Constants.PrimaryFont),)),
                                  //             Divider(height: 2,color: Constants.thirdColor,),
                                  //             SizedBox(height: 15.0,),
                                  //             Row(
                                  //               children: [
                                  //                 Text('10',style: TextStyle(color: Colors.black,fontFamily: Constants.PrimaryFont,fontSize: 14),),
                                  //               ],
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                )
                              ],
                            ),
                          );

                        },
                      ),);
                  }
              ),
            ),
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
      child:  messageNoti==null? Center(child: CircularProgressIndicator()):
      ListView(children: <Widget>[
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
        Container(
          color: Constants.thirdColorAccent,
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(5.0),
                child: Image.asset('assets/image/circular_home.png')),
            title: Text(
              "ပင်မစာမျက်နှာ",
              style: new TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 14.0),
            ),
            onTap: () {
              Navigator.pop(context);
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
        ///product
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/product.png')),
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