import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_pharmacy_order/model/MessageModel.dart';

class ChatService{
  FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<void> sendMessage(String userId,MessageModel messageModel) {
    CollectionReference reference= _db.collection('user').doc('$userId').collection('chat');
    reference.doc(messageModel.messageId)
        .set(messageModel.toMap()).then((value) => print("sended Message"))
        .catchError((error)=> print("failed to send Message"));
  }
  Future<void> deleteMessage(String userId,String messageId) {
    CollectionReference users = _db.collection('user').doc(userId).collection('chat');
    return users
        .doc('$messageId')
        .delete()
        .then((value) => print("message Deleted"))
        .catchError(
            (error) => print("Failed to delete message: $error"));
  }
}