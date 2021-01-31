import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/main.dart';
import 'package:uni_pharmacy_order/service/firebase_storage.dart';
import 'package:uni_pharmacy_order/service/firestore_service.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/HomePage.dart';
import 'package:uni_pharmacy_order/view/LoginPage.dart';
import 'package:uni_pharmacy_order/view/PriceList/PricePage.dart';
import 'package:uni_pharmacy_order/view/chat/ChatBox.dart';
import 'package:uni_pharmacy_order/view/contact/ContactPage.dart';
import 'package:uni_pharmacy_order/view/order/OrderPage.dart';
import 'package:uni_pharmacy_order/view/product/ProductDetail.dart';
import 'package:uni_pharmacy_order/view/product/ShowProduct.dart';
import 'package:uni_pharmacy_order/view/voucher/VoucherPage.dart';
import 'package:uni_pharmacy_order/widget/ProductCard.dart';
import 'package:uni_pharmacy_order/widget/TitleText.dart';



class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {


  final GlobalKey<ScaffoldState> _scaffoldKeyProduct = GlobalKey<ScaffoldState>();
  String userName,userId,searchName,messageNoti;
  bool initLoading,showSearchBar;
  ScrollController _controller = new ScrollController();
  FocusNode searchFocus;



  fetchData() async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    setState(() {
      userName=pref.getString("user_name");
      userId=pref.getString("uid");
    });
    FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
      int notiCount=int.parse(document.data()['message_noti'].toString());
      print("notiCOunt"+notiCount.toString());
      setState(() {
        messageNoti=notiCount.toString();
      });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      Firebase.initializeApp();
      initLoading=true;
      showSearchBar=false;
    });
    fetchData();
    super.initState();
    searchFocus=FocusNode();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKeyProduct,
          backgroundColor:Constants.thirdColor,
        endDrawer: new Drawer(
            child: HeaderOnly()),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            showSearchBar==true? IconButton(icon: Icon(Icons.close,color: Colors.black,), onPressed: (){
              setState(() {
                showSearchBar=false;
                searchName="";
              });
            }) : InkWell(child:messageNoti=="0"||messageNoti==null ?
            Image.asset('assets/image/menu.png',width: 30,):
            Badge(position:BadgePosition(top: 4,end: -5) ,
              badgeContent: Text(messageNoti.toString()),child:Image.asset('assets/image/menu.png',width: 30,) , ),onTap: (){
              ///Logics for notification
              _scaffoldKeyProduct.currentState.openEndDrawer();
            },),
            SizedBox(width: 10,),
          ],
          titleSpacing: 0,
          iconTheme: new IconThemeData(color: Constants.primaryColor),
          toolbarHeight: 70,
          backgroundColor: Colors.white,
          // Don't show the leading button
          title:showSearchBar==true?
          TextFormField(
            focusNode: searchFocus,
            keyboardType: TextInputType.name,
            style: TextStyle(
                fontSize: 17.0, fontFamily: Constants.PrimaryFont),
            onChanged: (value) {
              setState(() {
                searchName = value.toString().toLowerCase();
              });
            },
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(2),
                hintText: 'အမည်ဖြင့်ရှာမည်',
                prefixIcon: Icon(
                  Icons.search,
                  color: Constants.primaryColor,
                ),
                enabledBorder: new OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: new BorderSide(color: Colors.white),
                ),
                focusedBorder: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    new BorderSide(color: Colors.white)),
                border: new OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: new BorderSide(color: Colors.white),
                )),
          ):
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: (){
                  Get.offAll(HomePage());
                },
                  child: Image.asset('assets/image/logo.png',width: 95,)),
              Container(width: 130.0,
                  padding: EdgeInsets.only(left: 10),
                  child: Text('ကုန်ပစ္စည်းများ',style: TextStyle(color: Constants.primaryColor,fontSize: 18,),)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                IconButton(icon: Icon(Icons.search,color: Colors.black,),onPressed: (){
                  ///Logics for notification
                  setState(() {
                    showSearchBar=true;
                    searchFocus.requestFocus();
                  });
                },),
                  SizedBox(width: 10,),
              ],),
            ],
          ),
        ),
        body:SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/1.12,
            color:Constants.thirdColor,
            child: searchName==null || searchName==""?
            StreamBuilder<QuerySnapshot>(
                stream:FirestoreService().get('category'),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.hasError){
                    return Text('Something went wrong');
                  }if(!snapshot.hasData){
                    return Center(child: TitleText("No Data"));
                  }
                  if(snapshot.connectionState== ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return new ListView(
                    controller: _controller,
                    children: snapshot.data.docs.map((DocumentSnapshot document) {
                      return InkWell(
                        onTap: (){
                          FocusScope.of(context).requestFocus(FocusNode());
                          Get.to(ShowProduct(document.data()['category_name']));
                        },
                        child: new  Container(
                          padding: EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 33.0,
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                child: Text(
                                  document.data()['category_name'],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: Constants.PrimaryFont,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0,),
                              Container(
                                child: CachedNetworkImage(
                                  imageUrl: document.data()['category_image'],
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) => Container(
                                    height: 120.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(9),
                                      border:Border.all(color: Colors.black,width: 1),
                                      image: DecorationImage(
                                          image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) => Container(height: 100, child: Center(child: CircularProgressIndicator())),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                              SizedBox(height: 10.0,)
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }):
            StreamBuilder<QuerySnapshot>(
                    stream: (searchName=="" || searchName==null) ? FirestoreService().get('product'):FirebaseFirestore.instance
                        .collection('product').where("product_search", arrayContains : searchName).orderBy('product_name').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if(snapshot.data.toString()==""){
                        return Center(child: Text("No data",style: TextStyle(color: Colors.white),),);
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return new GridView(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5),
                        children: snapshot.data.docs
                            .map(
                              (DocumentSnapshot document) => InkWell(
                               onTap: (){
                                 FocusScope.of(context).requestFocus(FocusNode());
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductDetail(document.data()['product_name'],document.data()['product_image'],  document.data()['product_id'], document.data()['description'])));
                               },

                                child: ProductCard(
                                document.data()['product_id'],
                                document.data()['product_name'],
                                document.data()['description'],
                                document.data()['product_image'],
                                document.data()['category']),
                              ),
                        ).toList(),
                      );
                    }),
          ),
        )
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
  String userId,messageNoti ;
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
      child: messageNoti==null? Center(child: CircularProgressIndicator()):  ListView(children: <Widget>[
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
            Navigator.of(context).pop();
            Get.offAll(HomePage());
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
        Container(color: Constants.thirdColorAccent,
          child: ListTile(
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
            Navigator.of(context).pop();
            Get.to(PricePage());
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
            Navigator.of(context).pop();
            Get.to(OrderPage());
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
            Navigator.of(context).pop();
            Get.to(VoucherPage());
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
            Navigator.of(context).pop();
           Get.to(ChatBox());
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
              Navigator.of(context).pop();
              Get.to(ChatBox());
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
            Navigator.of(context).pop();
            Get.to(ContactPage());
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
                          Navigator.of(context).pop();
                          Get.offAll(LoginPage());
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
    var picture = await picker.getImage(source: ImageSource.gallery,imageQuality: 50);
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
    final picture = await picker.getImage(source: ImageSource.camera,imageQuality: 50);
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
