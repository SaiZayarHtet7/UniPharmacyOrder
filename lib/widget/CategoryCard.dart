import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';

Widget CategoryCard(String name,String url,String id){
  return Container(
    padding: EdgeInsets.all(0),
    height: 150,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border:Border.all(width: 1.0, color: Colors.white),
    ),
    child: Column(
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            height: 120.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18)),
              image: DecorationImage(
                  image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => Container(height: 120, child: Center(child: CircularProgressIndicator())),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        Container(
          child: Text('$name',style: TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 15,),),
        ),
      ],
    ),
  );
}