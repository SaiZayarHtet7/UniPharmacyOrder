import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:intl/intl.dart';
class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String userId,userName;
  var format =new DateFormat('dd-MM-yyyy hh:mm a');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  fetchData() async {
    SharedPreferences pref= await SharedPreferences.getInstance();
    setState(() {
      userId=pref.getString('uid');
      print(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 70,
      backgroundColor: Constants.thirdColor,
      leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,), onPressed: (){
        Navigator.of(context).pop();
      }),
      title: Text('အသိပေးချက်များ'),),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('user').doc(userId).collection("noti").orderBy('date_time',descending: true).limit(50).snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return Container(
                child: ListView(
                  shrinkWrap: true,
                  children: snapshot.data.docs.map((DocumentSnapshot document)
                  {
                    // return PriceCard(document.data()['price_kind'], document.data()['quantity'], document.data()['unit'], document.data()['price']);
                    return Column(
                      children: [
                        ListTile(
                          leading: CachedNetworkImage(
                            imageUrl:"https://firebasestorage.googleapis.com/v0/b/unipharmacy-a5219.appspot.com/o/logo.jpg?alt=media&token=cc9cd6ad-d5c0-4326-98bb-2397166ece6b",
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
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                          title: Text(document.data()['noti_title'],style: TextStyle(fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5,),
                              Text(document.data()['noti_text'],style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black),textAlign: TextAlign.justify,),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding:EdgeInsets.only(top: 15),
                                  child: Text(format.format(DateTime.fromMicrosecondsSinceEpoch(int.parse(document.data()['date_time'].toString())*1000)).toString(),
                                    style: TextStyle(fontFamily: Constants.PrimaryFont,),),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:8.0),
                          child: Divider(thickness: 1.2,color: Constants.secondaryColor,),
                        )
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
      ),
    );

  }
}
