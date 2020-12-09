import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uni_pharmacy_order/service/firestore_service.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService{
  var uuid=Uuid();
 Future<void> UploadSlidePhoto(String path,File image) async{
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('$path/${Path.basename(image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;
    print('$path image Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
        print(fileURL);
        FirestoreService().add('$path', fileURL,uuid.v4());
    });
}


Future<String> UploadPhoto(String path,File image) async{
  String url="";
   StorageReference storageReference=FirebaseStorage.instance.ref()
       .child('$path/${Path.basename(image.path)}');
   StorageUploadTask uploadTask = storageReference.putFile(image);
  var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  url = downUrl.toString();
  return url;
}

  Future<void> DeletePhoto(String imageUrl){
    FirebaseStorage.instance
        .getReferenceFromUrl(imageUrl)
        .then((res) {
      res.delete().then((res) {
        print("Image Deleted!");
      });
        });
 }
 Future <String> EditPhoto(String delimageUrl,String path,File image) async{
   DeletePhoto(delimageUrl);
   return await UploadPhoto(path, image);
}

}

