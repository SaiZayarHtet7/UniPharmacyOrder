import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';

Widget ProductInPriceList(String productId, String priceKind){
  return Center(
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('product').doc(productId).collection("price").where("price_kind",isEqualTo: priceKind).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return new ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: snapshot.data.documents.map((DocumentSnapshot document) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 5,vertical:5),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:MainAxisAlignment.end,
                children: [
                  Text(Constants().oCcy.format(int.parse(document.data()['price']) ),style: TextStyle(fontFamily: Constants.PrimaryFont, color: Constants.primaryColor),),
                ],
              ),
            );
          }).toList(),
        );
      },
    ),
  );
}