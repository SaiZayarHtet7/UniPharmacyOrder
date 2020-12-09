import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/notification/NotificationPage.dart';

Widget NotiIcon(BuildContext context, String userId,notiCount){
  return Container(
    height: 50,
    width: 50,
    child:notiCount=="0" || notiCount==null?
    IconButton(icon: Icon(Icons.notifications,color: Colors.black),):
    Badge(
      position: BadgePosition(top: -5,start: 30),
      badgeContent: Text(notiCount),
      child: IconButton(icon: Icon(Icons.notifications,color: Colors.black),),
    ),
  );
}