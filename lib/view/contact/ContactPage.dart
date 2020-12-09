import 'dart:core';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:url_launcher/url_launcher.dart';


class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        toolbarHeight: 70,
        title: Text('ဆက်သွယ်ရန်',style: TextStyle(fontFamily: Constants.PrimaryFont),),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: (){
          Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:  EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child:
              CachedNetworkImage(
                imageUrl:"https://firebasestorage.googleapis.com/v0/b/unipharmacy-a5219.appspot.com/o/logo.jpg?alt=media&token=cc9cd6ad-d5c0-4326-98bb-2397166ece6b",
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  width:150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black,width: 0.5),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),),
              SizedBox(height: 20.0,),
              Text('UNI (You and I) The best partners',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,fontSize: 16),),
              SizedBox(height: 30.0,),

              ///Address
              TitleWidget('Address'),
              SizedBox(height: 5.0,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on,color: Constants.thirdColor,size: 30,),
                  SizedBox(width: 10.0,),
                  Expanded(
                    flex: 1,
                      child: Text('140/1 Thit Sar street. Zayy Paing Quarter.Taunggyi, Shan State, Myanmar',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,fontSize: 16,height: 1.8,),))
                ],
              ),
              SizedBox(height: 30.0,),


              ///Contact
              TitleWidget('Phone Number'),
              SizedBox(height: 10.0,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.phone,color: Constants.thirdColor,size: 30,),
                  SizedBox(width: 10.0,),
                  Expanded(
                      flex: 1,
                      child: Text('09-796 462 070',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,fontSize: 16,height: 1.8,),)),
                   ButtonTheme(
                     padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0), //adds padding inside the button
                     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, //limits the touch area to the button area
                     minWidth: 0, //wraps child's width
                     height: 0,
                     child: RaisedButton(

                       shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),

                        ),
                      color: Constants.thirdColor,
                        child: Text('Call',style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont,fontSize: 16),),
                        elevation: 5,
                        onPressed: () async{
                          String telephoneUrl = "tel:09796462070";

                          if (await canLaunch(telephoneUrl)) {
                          await launch(telephoneUrl);
                          } else {
                          throw "Can't phone that number.";
                          }
                    }),
                  ),
                ],
              ),
              SizedBox(height: 30.0,),

              ///Facebok
              TitleWidget('Facebook Page'),
              SizedBox(height: 10.0,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.web_outlined,color: Constants.thirdColor,size: 30,),
                  SizedBox(width: 10.0,),
                  Expanded(
                      flex: 1,
                      child: Text('UNI Pharmacy',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,fontSize: 16,height: 1.8,),)),
                  InkWell(
                    onTap: () async {
                      String fbProtocolUrl;
                        fbProtocolUrl = 'fb://page/2131843647034836';


                      String fallbackUrl = 'https://www.facebook.com/https://www.facebook.com/Linmoelat';

                      try {
                        bool launched = await launch(fbProtocolUrl, forceSafariVC: false);

                        if (!launched) {
                          await launch(fallbackUrl, forceSafariVC: false);
                        }

                      } catch (e) {
                        await launch(fallbackUrl, forceSafariVC: false);
                      }
                    },
                    child: Container(
                      width: 70,
                        child: Center(child: Image.asset('assets/image/facebook.png',width: 40,))),
                  )
                ],
              ),
              SizedBox(height: 30.0,),

              ///Developer
              TitleWidget('Developed by'),
              SizedBox(height: 10.0,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.developer_mode,color: Constants.thirdColor,size: 30,),
                  SizedBox(width: 10.0,),
                  Expanded(
                      flex: 1,
                      child: Text('Sai Zayar Htet',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,fontSize: 16,height: 1.8,),)),

                ],
              ),
              SizedBox(height: 10.0,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.phone,color: Constants.thirdColor,size: 30,),
                  SizedBox(width: 10.0,),
                  Expanded(
                      flex: 1,
                      child: Text('09-683 064 033',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Colors.black,fontSize: 16,height: 1.8,),)),
                  ButtonTheme(
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0), //adds padding inside the button
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, //limits the touch area to the button area
                    minWidth: 0, //wraps child's width
                    height: 0,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),

                        color: Constants.thirdColor,
                        child: Text('Call',style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont,fontSize: 16),),
                        elevation: 5,
                        onPressed: () async {
                          String telephoneUrl = "tel:09683064033";

                          if (await canLaunch(telephoneUrl)) {
                          await launch(telephoneUrl);
                          } else {
                          throw "Can't phone that number.";
                          }
                        }),
                  ),
                ],
              ),
              SizedBox(height: 30.0,)
            ],
          ),
        ),
      ),
    );
  }
  Widget CustomDivider(){
    return Divider(color: Colors.grey,thickness: 0.5,);
  }
  Widget TitleWidget(String titleText){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 1,child:CustomDivider()),
        SizedBox(width: 15,),
        Center(child: Text('$titleText',style: TextStyle(fontFamily: Constants.PrimaryFont,color: Constants.primaryColor,fontSize: 17),),),
        SizedBox(width: 15,),
        Expanded(flex: 1,child:CustomDivider()),
      ],
    );
  }
}
