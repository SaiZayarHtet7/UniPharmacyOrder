


import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as httpLib;
class NotiService{
  List<String> tokenList=List();
  String adminToken;
Future<void> sendNoti(String title,String body){

  FirebaseFirestore.instance.collection("user").where('is_admin',isEqualTo: true ).get().then((querySnapshot) {
    querySnapshot.docs.forEach((result) async {
      tokenList.add(result.data()['token']);
      adminToken=tokenList[0].toString();
      print('Token <>>>'+adminToken);

      final response = await httpLib
          .post(
          'https://fcm.googleapis.com/fcm/send',
          headers: {
            "Accept": "application/json",
            'Content-type': 'application/json',
            'Authorization': 'key=AAAA_TFyCCI:APA91bFRjYi7VAeWA2FX3QSXnVpc6qse3CDan4oy3rQMe-NedbEa7J5Tm3QePc4M5tYxQ6gVOMAiZ9GAwnukE4Ub8OBHQ3D57i668NaDpBzFLpB7T0z1aBBfuexTrebYNwHho1Q9KvtM'
          },
          body: json.encode({
            'notification':{
              "body": "$body",
              "title": "$title",
              "sound": 'default',
              "android_channel_id": "id",
              "image": "https://firebasestorage.googleapis.com/v0/b/unipharmacy-a5219.appspot.com/o/logo.png?alt=media&token=cba61f0e-49d5-4475-a420-e1dc7cd6e4d9"
            },
            "priority": "high",
            "data": {
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "id": "1",
              "status": "done"
            },
            "to": "$adminToken"
          }))
          .catchError((onError) {
        print(onError);
        throw Exception('Failed to load ');
      });
    });
  });
}
}