import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';

Widget VoucherCard(String date ,String voucherNo, String status){


  String convertDate(String dateTime ){
    return date.substring(0,10);
  }
  
  String convertVoucher(String vNo){
    do{
      vNo="0"+vNo;
    }while(vNo.length<5);
    return  vNo;
  }
  return Card(
    color: Colors.white,
    child: Container(
      height: 60,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container( width: 75,
              child: Text(convertDate(date))),
          Text(convertVoucher(voucherNo),style: TextStyle(color: status==Constants.orderPrepare ? Colors.green: Constants.primaryColor),),
          Container(
            width: 130,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:status==Constants.orderPrepare ? Colors.green: Constants.primaryColor
            ),
              child: Text(status,textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: Constants.PrimaryFont),)),
        ],
      ),
    ),
  );
}