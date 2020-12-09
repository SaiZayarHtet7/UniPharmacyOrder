import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';

Widget TextDataColor(String data){
  return Text("$data",style: TextStyle(color: Constants.thirdColor,fontSize: 13,fontFamily: Constants.PrimaryFont),);
}