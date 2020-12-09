import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';

class Constants{

  static Color primaryColor=Color.fromRGBO(255, 131, 3, 1);
  static Color secondaryColor=Color.fromRGBO(29, 157, 171, 1);
  static Color successColor=Color.fromRGBO(61, 139, 79, 1);
  static Color thirdColor=Hexcolor("#67b641");
  static Color emergencyColor=Colors.red[600];
  static Color TextFieldColor=Colors.grey;
  static Color DisableColor=Colors.grey;
  static String PrimaryFont='OpenSans';

  static String orderDeliver='ပစ္စည်းပို့ပြီး';
  static String orderPrepare='ပစ္စည်းပြင်ဆင်ဆဲ';

  static Color thirdColorAccent=Hexcolor("#9967b641");

  final NumberFormat oCcy = new NumberFormat("#,###", "en_US");
  static  const kHeadingTextStyle = TextStyle(
    fontSize: 22,
  );

  setSearchParam(String caseNumber) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
}