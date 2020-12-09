import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_splash/flutter_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/HomePage.dart';
import 'package:uni_pharmacy_order/view/LoginPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences preferences=await SharedPreferences.getInstance();
  String userName=preferences.getString('user_name');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MaterialApp(home:
      Splash(
        seconds: 3,
        navigateAfterSeconds: userName == null ? LoginPage() : HomePage(),
        image: Image.asset('assets/image/logoCircle.png',),

        backgroundColor:Constants.primaryColor,
        title: Text('UNI Pharmacy application မှ ကြိုဆိုပါသည်',style: TextStyle(color: Colors.white,fontFamily: Constants.PrimaryFont),),
        photoSize: 100,
        loaderColor: Colors.white ,
      ),));
}