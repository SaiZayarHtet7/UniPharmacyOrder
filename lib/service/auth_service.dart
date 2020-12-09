import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_pharmacy_order/model/user_model.dart';
import 'package:uni_pharmacy_order/service/firestore_service.dart';

class  AuthService{
  final FirebaseAuth _auth=FirebaseAuth.instance;

  //Sign In
  Future<String> register(String name,String phone,String address,String email,String password) async {
    String status;
    try {
      UserCredential response = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print(response);
      return 'success';
      // response.user.uid
    } on FirebaseAuthException catch (e) {
      if(e.code == 'weak-password'){
        return 'The password provided is too weak.';
      }else if(e.code=='email-already-in-use'){
       return  'The account already exists for that email.';
      }
    } catch (e){
      print("error$e");
      return "error";
    }
    return status;
  }

  Future<String> signin(String email, String password) async {
    try {
      UserCredential response = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // response.user.uid;
      return 'success';
    }  on FirebaseAuthException catch(e){
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    } catch (e) {
      print(e);
    }
  }

}