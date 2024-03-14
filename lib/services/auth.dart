import 'package:skyscape/models/newuser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //sign in annoymoulsy and with email and password
  //register with emial&password
  //also sign out in the future tutiral 9

 //focus in sign in annoymously cause its the easiest

  final FirebaseAuth _auth = FirebaseAuth.instance;                  //_ underscosre means that the property is private and I can only use it in this file
  //an instance of firebaseauth.

  //create user object bsaed on firebaseuser
  Newuser? _userfromFirebaseUser(User? user) {
    return user != null ? Newuser(uid: user.uid) : null; // provide a default value or handle null case
  }


  //auth changes user strream
  Stream<Newuser?> get user {
    
    return _auth.authStateChanges()
      .map((User? user) => _userfromFirebaseUser(user));
      //everytime a usre sign in or sign out, we will get soe sort of even down the srream

  }
  //sign in is a an asynchronous task, return a future
  Future signInAnon() async{
    try { //some kind of authentication result
      UserCredential result = await _auth.signInAnonymously();   //AuthResult changed to UserCredential
      User? user = result.user;                      //FirebaesUser changed to user
      return user;  //if successful
    }catch(e){
        print(e.toString());
        return null;  //if not succesful
    }
  }




///////////////////////////////////Sign in with email and password///////////////////
  Future signInwithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userfromFirebaseUser(user); //convert firebase user to our own newuserclass user
    } catch (e){
      print(e.toString());
      return null;
    }
  }

///////////////////////////Register with email and password///////////////////////
  Future registerwithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userfromFirebaseUser(user); //convert firebase user to our own newuserclass user
    } catch (e){
      print(e.toString());
      return null;
    }
  }



  /////////////////////////////SIGN OUT///////////////////////////////////////////
  Future signOut() async{
    try{
      
      
      await _auth.signOut();  //signout is built in method
      print("signout function taking place");
     
      return null;
      
    } catch(e){
      print("catch e for signout");
      print(e.toString());
      return null;
    }
  }
}