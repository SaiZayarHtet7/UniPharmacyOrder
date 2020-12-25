import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/model/MessageModel.dart';
import 'package:uni_pharmacy_order/service/ChatService.dart';
import 'package:uni_pharmacy_order/service/NotiService.dart';
import 'package:uni_pharmacy_order/service/firebase_storage.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/HomePage.dart';
import 'package:uni_pharmacy_order/view/LoginPage.dart';
import 'package:uni_pharmacy_order/view/PriceList/PricePage.dart';
import 'package:uni_pharmacy_order/view/contact/ContactPage.dart';
import 'package:uni_pharmacy_order/view/order/OrderPage.dart';
import 'package:uni_pharmacy_order/view/product/ProductPage.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  ///Declaration
  bool loading;
  String userName,userId;
  int current = 0;
  List<String> imgList = [];
  var format =new DateFormat('dd-MM-yyyy hh:mm a');
  final messageController = TextEditingController();
  var uuid=Uuid();
  final picker = ImagePicker();
  String msg;
  String token;
  File messageImage;

  fetchData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userName = pref.getString("user_name");
      userId=pref.getString('uid');
    });
  }

  Future<bool> _onWillPop() async {
    print('Chat Box Back');
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

  @override
  void initState() {
    // TODO: implement initState
    loading = true;
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            key: _scaffoldKey,
            endDrawer: new Drawer(child: HeaderOnly()),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              iconTheme: new IconThemeData(color: Constants.primaryColor),
              toolbarHeight: 70,
              backgroundColor: Colors.white,
              actions: [
                InkWell(child: Image.asset('assets/image/menu.png',width: 30,),onTap: (){
                  ///Logics for notification
                  _scaffoldKey.currentState.openEndDrawer();
                },),
                SizedBox(width: 10.0,)
              ],
              // Don't show the leading button
              title:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/image/logo.png',width: 95,),
                  Container(width: 130.0,
                      child: Center(child: Text('စကားပြောခန်း',style: TextStyle(color: Constants.primaryColor,fontSize: 18,),))),
                      SizedBox(width: 50,),
                ],
              ),
            ),
          body: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 60),
                child: StreamBuilder<QuerySnapshot>(
                  stream:FirebaseFirestore.instance.collection('user').doc('$userId').collection('chat').orderBy('created_date',descending: true).limit(300).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Container(child: CircularProgressIndicator(),));
                    }
                    return ListView(
                      reverse: true,
                      children: snapshot.data.docs.map((DocumentSnapshot document) {
                        bool showDate;
                        return Align(
                          alignment:document.data()['sender']=="user" ?Alignment.centerRight :Alignment.centerLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:document.data()['sender']=="user"?CrossAxisAlignment.end: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 10.0,),
                                  document.data()['sender']=="user" ?SizedBox():

                                  CachedNetworkImage(
                                    imageUrl:"https://firebasestorage.googleapis.com/v0/b/unipharmacy-a5219.appspot.com/o/logo.jpg?alt=media&token=cc9cd6ad-d5c0-4326-98bb-2397166ece6b",
                                    fit: BoxFit.cover,
                                    imageBuilder: (context, imageProvider) => Container(
                                      width:35.0,
                                      height: 35.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider, fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      print("hello");
                                      setState(() {
                                        if(showDate==false){
                                          showDate=true;
                                        }else{
                                          showDate=false;
                                        }
                                      });
                                      print(showDate);
                                    },
                                    onLongPress: (){
                                      print('long');
                                      if(document.data()['sender'] == "user") {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                                title: Text(
                                                    'ပို့ထားသောစာကို ဖျက်မည်လား?',
                                                    style: new TextStyle(
                                                        fontSize: 20.0,
                                                        color: Constants
                                                            .thirdColor,
                                                        fontFamily: Constants
                                                            .PrimaryFont)),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('ဖျက်မည်',
                                                        style: new TextStyle(
                                                            fontSize: 16.0,
                                                            color: Constants
                                                                .primaryColor,
                                                            fontFamily: Constants
                                                                .PrimaryFont
                                                        ),
                                                        textAlign: TextAlign
                                                            .right),
                                                    onPressed: () async {
                                                      ChatService().deleteMessage(userId, document.data()['message_id']);
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text('မဖျက်ပါ',
                                                        style: new TextStyle(
                                                            fontSize: 16.0,
                                                            color: Constants
                                                                .primaryColor,
                                                            fontFamily: Constants
                                                                .PrimaryFont
                                                        ),
                                                        textAlign: TextAlign
                                                            .right),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  )
                                                ],
                                              ),
                                        );
                                      }else{
                                      }
                                    },
                                    child: document.data()['message_type']=="image"?
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LargeImage(document.data()['message_text'])),
                                        );
                                      },
                                      child: Container(
                                        width:  MediaQuery.of(context).size.width/1.4,
                                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(color:document.data()['sender']=="user" ? Constants.thirdColor:Colors.grey[300],
                                            borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft:Radius.circular(10),bottomLeft: Radius.circular(document.data()['sender']=="user" ?10:0),bottomRight: Radius.circular(document.data()['sender']=="user" ?0:10))),
                                        child: Column(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:document.data()['message_text'],
                                              fit: BoxFit.fitWidth,
                                              placeholder: (context, url) => CircularProgressIndicator(),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ): Container(
                                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                        constraints: BoxConstraints( maxWidth: MediaQuery.of(context).size.width/1.4),
                                        decoration: BoxDecoration(color:document.data()['sender']=="user" ? Constants.thirdColor:Colors.grey[300],
                                            borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft:Radius.circular(10),bottomLeft: Radius.circular(document.data()['sender']=="user" ?10:0),bottomRight: Radius.circular(document.data()['sender']=="user" ?0:10))),
                                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                        child: Text(document.data()['message_text'],style: TextStyle(color:document.data()['sender']=="user" ? Colors.white :Colors.black,fontSize: 16),)
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin:document.data()['sender']=="user"? EdgeInsets.symmetric(horizontal: 10.0):EdgeInsets.only(left: 50),
                                child: Text(format.format(DateTime.fromMicrosecondsSinceEpoch(int.parse(document.data()['created_date'].toString())*1000)).toString(),
                                  style: TextStyle(color: Colors.grey,fontSize:13),),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child:  Container(
                  height: 50.0,
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: IconButton(icon: Icon(Icons.camera_alt), onPressed: (){
                            _openCamera(context);
                          }),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(icon: Icon(Icons.photo), onPressed: (){
                            _openGallary(context);
                          }),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(0),
                            height: 50,
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              onChanged: (v){

                              },
                              style: TextStyle(
                                  fontSize: 15.0, fontFamily: Constants.PrimaryFont),
                              controller: messageController,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  hintText: 'စာတို',
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: new BorderSide(color: Colors.black,width: 1),
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: new BorderSide(color: Colors.black,width: 1),),
                                  border: new OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: new BorderSide(color: Colors.black,width: 1),
                                  )),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(icon: Icon(Icons.send,color: Constants.primaryColor,), onPressed: (){
                            if(messageController.text==null || messageController.text==""){
                              ///Nothing work
                            }else{
                              int dateTime= DateTime.now().millisecondsSinceEpoch;
                              FirebaseFirestore.instance.collection('user').doc(userId)
                                  .update({'final_chat_date_time': dateTime,
                                'is_new_chat':"old"})
                                  .then((value) => print("User Updated"))
                                  .catchError((error) => print("Failed to update user: $error"));
                              MessageModel messageModel= MessageModel(
                                  messageId: uuid.v4(),
                                  sender: "user",
                                  msgText: messageController.text,
                                  msgType: "text",
                                  createdDate:dateTime
                              );
                              ChatService().sendMessage(userId, messageModel);
                              print(token);
                              NotiService().sendNoti("$userName send a message",messageController.text);
                              messageController.text="";
                              FirebaseFirestore.instance.collection('user').doc(userId)
                                  .update({'status': 'unread'})
                                  .then((value) => print("User Updated"))
                                  .catchError((error) => print("Failed to update user: $error"));
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ) ,
        ),
      ),
    );
  }

  Future _openGallary(BuildContext context) async {
    var picture = await picker.getImage(source: ImageSource.gallery);
    File tmpFile = File(picture.path);
    messageImage= tmpFile;
    String imageLink=await FirebaseStorageService().UploadPhoto('chat', messageImage);
    MessageModel messageModel= MessageModel(
        messageId: uuid.v4(),
        sender: "user",
        msgText: imageLink,
        msgType: "image",
        createdDate:DateTime.now().millisecondsSinceEpoch
    );

    ChatService().sendMessage(userId, messageModel);
    NotiService().sendNoti("$userName", "send a photo");
    FirebaseFirestore.instance.collection('user').doc(userId)
        .update({'status': 'unread'})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future _openCamera(BuildContext context) async {
    final picture = await picker.getImage(source: ImageSource.camera);
    File tmpFile = File(picture.path);
    messageImage= tmpFile;
    String imageLink=await FirebaseStorageService().UploadPhoto('chat', messageImage);
    MessageModel messageModel= MessageModel(
        messageId: uuid.v4(),
        sender: "user",
        msgText: imageLink,
        msgType: "image",
        createdDate:DateTime.now().millisecondsSinceEpoch
    );
    ChatService().sendMessage(userId, messageModel);
    NotiService().sendNoti("$userName", "send a photo");
    FirebaseFirestore.instance.collection('user').doc(userId)
        .update({'status': 'unread','message_noti':0})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
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
    loading = true;
    super.initState();
  }

  fetchData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    userName = pref.getString('user_name');
    userPhoto = pref.getString('user_photo');
    phoneNumber = pref.getString('phone_number');
    address = pref.getString('address');
    userId = pref.getString('uid');

    FirebaseFirestore.instance.collection("user").doc(userId).get().then((DocumentSnapshot document) {
      int notiCount=int.parse(document.data()['message_noti'].toString());
      print("notiCOunt"+notiCount.toString());
      setState(() {
        messageNoti=notiCount.toString();
      });
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: messageNoti==null? Center(child: CircularProgressIndicator()):ListView(children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Constants.primaryColor),
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

              SizedBox(
                height: 10.0,
              ),

              Text(
                userName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: Constants.PrimaryFont),
              )
            ],
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "Menu",
              style: TextStyle(
                  fontFamily: Constants.PrimaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 10.0,
        ),

        ///home
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/circular_home.png')),
          title: Text(
            "ပင်မစာမျက်နှာ",
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont, fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
              child: Image.asset('assets/image/product.png'),
            ),
          ),
          title: Text(
            "ကုန်ပစ္စည်း",
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont, fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont, fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PricePage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont, fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont, fontSize: 14.0),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
            Navigator.pop(context);
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
              Navigator.pop(context);
              FirebaseFirestore.instance.collection('user').doc(userId)
                  .update({'message_noti':0})
                  .then((value) => print("User Updated"))
                  .catchError((error) => print("Failed to update user: $error"));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
          child: Divider(
            thickness: 1,
            color: Constants.thirdColor,
            height: 5,
          ),
        ),

        SizedBox(
          height: 30.0,
        ),
        Container(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "General",
              style: TextStyle(
                  fontFamily: Constants.PrimaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
        SizedBox(
          height: 10.0,
        ),
        ListTile(
          leading: Container(
              padding: EdgeInsets.all(5.0),
              child: Image.asset('assets/image/contact.png')),
          title: Text(
            "ဆက်သွယ်ရန်",
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont, fontSize: 14.0),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactPage()));
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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
            style: new TextStyle(
                fontFamily: Constants.PrimaryFont,
                fontSize: 14.0,
                color: Constants.primaryColor),
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
          padding: const EdgeInsets.only(left: 80.0, right: 10.0),
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

class LargeImage extends StatelessWidget {
  String imgUrl;
  LargeImage(this.imgUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child:InkWell(
        onTap: (){
          Navigator.of(context).pop();
        },
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) => Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.fitWidth),
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),),
    );
  }
}
