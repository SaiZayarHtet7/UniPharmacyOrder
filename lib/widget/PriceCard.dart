import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';

Widget PriceCard(String quantity,String unit,String price ){
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex:1,
            child: Row(

              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 20.0,),
                Text(quantity,style: TextStyle(color: Constants.thirdColor,fontSize: 16.0,fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                SizedBox(width: 5.0,),
                Text(unit,style: TextStyle(fontSize: 15.0,fontFamily: Constants.PrimaryFont),)
              ],
            ),
          ),
          SizedBox(width: 10.0,),
          Expanded(
            flex  : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Constants().oCcy.format(int.parse(price)) ,style: TextStyle(color: Constants.thirdColor,fontSize: 16.0,fontFamily: Constants.PrimaryFont,fontWeight: FontWeight.bold),),
                SizedBox(width: 5.0,),
                Text("ကျပ်",style: TextStyle(fontSize: 15.0,fontFamily: Constants.PrimaryFont),),
                SizedBox(width: 20.0,),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 10,),
      Divider(color: Colors.grey,)
    ],
  );
}