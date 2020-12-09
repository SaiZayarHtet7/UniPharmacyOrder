class MessageModel {

  String messageId;
  String msgText;
  String msgType;
  String sender;
  int createdDate;

  MessageModel({this.messageId, this.msgText , this.msgType,this.sender,this.createdDate});

  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'message_text':msgText,
      'message_type': msgType,
      'sender':sender,
      'created_date':createdDate,
    };
  }
}