/*
import "package:flutter/material.dart";
import "package:skyscape/services/auth.dart";
import 'package:flutter/gestures.dart';


class Register extends StatefulWidget {

  final Function toggleView;

  const Register({required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {


  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.0,  //removes drop shadow
        title: const Text('Create an Account'),
        centerTitle: true,
      ),

      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Form(
          key: _formKey,
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

                const Text(
                  "Welcome to SkyScape!",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text("Never miss the golden hour again."),
                const SizedBox(height: 20.0),


              //EMAIL//
              SizedBox(height:20.0),
              TextFormField(
                decoration:InputDecoration(
                  hintText: 'Email',
                ),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(()=>email = val); //setting email = whatever value val is
                }
              ),           //for email
              

              //PASSWORD//
              SizedBox(height:20.0),
              TextFormField(
                
                validator: (val) => val!.length <  6  ? 'Enter a valid password' : null,
                obscureText: true,
                onChanged: (val){
                  setState(()=>password = val);
                }//for password
              ),
              
              SizedBox(height:30.0),
                Text.rich(
                TextSpan(
                  
                  text: 'Already have an account? Click ',
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'here',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          widget.toggleView();
                        },
                    ),
                    const TextSpan(
                      text: ' to log in!',
                      style: TextStyle(color: Colors.black),
                    ),
                   
                  ],
                ),
                ),

                SizedBox(
                  width: 400.0, // Width of the SizedBox
                  height: 100.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0), // Adjust padding values
                    child: ElevatedButton(
                      onPressed: () async{
                      
                        if (_formKey.currentState?.validate()?? false){
                          dynamic result = await _auth.registerwithEmailAndPassword(email,password);      
                            //dynamic cause can be null or user
                          if(result == null){
                            setState(() => error = 'Please supply a valid email');
                          }
                          print(email);
                          print(password);
                          print('hello');
                          
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0), 
                        ),
                        backgroundColor: Colors.amber, 
                        elevation: 5, // Add shadow to the button
                      ),
                      child: const Text(
                        'Register and Login',
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        ),
                      ),
                    ),

                  ),
                ),
                SizedBox(height:12.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
            ]
          )
        ),
      ),
    );
}
}



*/

/*
import "package:flutter/material.dart";
import "package:skyscape/services/auth.dart";
import 'package:flutter/gestures.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  const Register({required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[150],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.0, //removes drop shadow
        title: const Text('Create an Account'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Welcome to SkyScape!",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 5.0),
              const Text("Never miss the golden hour again."),
              const SizedBox(height: 20.0),

              //EMAIL//
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                    suffixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val); //setting email = whatever value val is
                  },
                ),
              ),

              //PASSWORD//
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                    suffixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Enter a valid password' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
              ),

              const SizedBox(height: 30.0),
              Text.rich(
                TextSpan(
                  text: 'Already have an account? Click ',
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'here',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          widget.toggleView();
                        },
                    ),
                    const TextSpan(
                      text: ' to log in!',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 400.0, // Width of the SizedBox
                height: 100.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0), // Adjust padding values
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        dynamic result = await _auth.registerwithEmailAndPassword(email, password);
                        //dynamic cause can be null or user
                        if (result == null) {
                          setState(() => error = 'Please supply a valid email');
                        }
                        print(email);
                        print(password);
                        print('hello');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.amber,
                      elevation: 5, // Add shadow to the button
                    ),
                    child: const Text(
                      'Register and Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


*/


import "package:flutter/material.dart";
import "package:skyscape/services/auth.dart";
import 'package:flutter/gestures.dart';


class Register extends StatefulWidget {
  final Function toggleView;

  const Register({required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[150],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.0,
        title: const Text('Create an Account'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Welcome to SkyScape!",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 5.0),
              const Text("Never miss the golden hour again."),
              const SizedBox(height: 20.0),

              // USERNAME
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Username',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                    suffixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                  onChanged: (val) {
                    setState(() => username = val);
                  },
                ),
              ),

              // EMAIL
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                    suffixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
              ),

              // PASSWORD
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                    suffixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Enter a valid password' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
              ),

              const SizedBox(height: 30.0),
              Text.rich(
                TextSpan(
                  text: 'Already have an account? Click ',
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'here',
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          widget.toggleView();
                        },
                    ),
                    const TextSpan(
                      text: ' to log in!',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 400.0,
                height: 100.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        dynamic result = await _auth.registerwithEmailAndPassword(email, password, username);
                        if (result == 'Username already taken') {
                         setState(() => error = 'Username is already taken.\nPlease choose a different username.');}
                        else if (result == null) {
                          setState(() => error = 'Please supply a valid email');
                        }
                        print(email);
                        print(password);
                        print(username);
                        
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.amber,
                      elevation: 5,
                    ),
                    child: const Text(
                      'Register and Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}