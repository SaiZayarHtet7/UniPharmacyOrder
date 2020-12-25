import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uni_pharmacy_order/util/constants.dart';

Widget ProductCard(String id, String name, String description, String photo,
    String category) {
  return
    Container(
    padding: EdgeInsets.all(0),
    height:140,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          height: 33,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  '$name',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: Constants.PrimaryFont,
                    fontSize: 17,
                  ),
                ),],
            ),
          ),
        ),
        SizedBox(height: 5.0,),
        Container(
          child: CachedNetworkImage(
            imageUrl: photo,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) => Container(
              height: 117.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border:Border.all(color: Colors.black,width: 1),
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => Container(height: 100, child: Center(child: CircularProgressIndicator())),
            errorWidget: (context, url, error) => Container(
              height: 115.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border:Border.all(color: Colors.black,width: 1),
                image: DecorationImage(
                  image: AssetImage(
                      'assets/image/logo.jpg'),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.rectangle,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.0,)
      ],
    ),
  );
}