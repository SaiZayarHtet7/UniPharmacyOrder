class NotiModel {

  String notiId;
  String notiText;
  String notiTitle;
  String notiType;
  String sender;
  String photo;
  int createdDate;

  NotiModel({this.notiId, this.notiTitle,this.notiText , this.notiType,this.sender,this.photo,this.createdDate});

  Map<String, dynamic> toMap() {
    return {
      'noti_id': notiId,
      'noti_title':notiTitle,
      'noti_text':notiText,
      'noti_type': notiType,
      'sender':sender,
      'photo':photo,
      'created_date':createdDate,
    };
  }
}