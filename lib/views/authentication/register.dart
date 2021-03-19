import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  TextEditingController emailController = new TextEditingController();
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController verifyPasswordController = new TextEditingController();




  Widget _buildPopupDialog(BuildContext context, String title, String body, bool isShow) {
  return new AlertDialog(
    title: Text(title),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(body),
      ],
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: ()  {
         (isShow) ? Navigator.pushReplacementNamed(context, '/loginpage') : Navigator.pop(context);
        },
        textColor: Theme.of(context).primaryColor,
        child: (isShow) ? const Text('Proceed to Login') : const Text('Try Again'),
      ),
    ],
  );
    }

  @override
  Widget build(BuildContext context) {
    final firstNameField = TextField(
          controller: firstNameController,
          obscureText: false,
          style: style,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              hintText: "First Name",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        );
    final lastNameField = TextField(
          controller: lastNameController,
          obscureText: false,
          style: style,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              hintText: "Last Name",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        );
    final emailField = TextField(
          controller: emailController,
          obscureText: false,
          style: style,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              hintText: "Email",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        );
        final passwordField = TextField(
          controller: passwordController,
          obscureText: true,
          style: style,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              hintText: "Password",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        );
        final verifyPasswordField = TextField(
          controller: verifyPasswordController,
          obscureText: true,
          style: style,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              hintText: "Verify Password",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        );
        final registerButton = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xFFD32F2F),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () async {
              if (verifyPasswordController.text == passwordController.text){
                
          Map dataSend = {
              "LastName": lastNameController.text,
              "FirstName": firstNameController.text,
              "emailAddress": emailController.text,
              "password": passwordController.text,
              "userLevel": "resident"
            };
            
          // var body = json.encode(dataSend);


          final response = await http.post(
            Uri.http('192.168.0.127', 'tabang/event.php'),
            // headers: <String, String>{
            //   "Content-Type": "application/json",
            // },
            body: dataSend,
          );

          // print(body);
          if (response.body == "New record created successfully") {

         
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context,"Success Registration", "You have registered Successfully "+ lastNameController.text + ", "+firstNameController.text,true),
                ); 
                }
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context,"Please verify your password", "You didn't input the same password. Please Recheck",false),
                ); 
              }
            },
            child: Text("Register",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );

         return Scaffold(
          body: Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // SizedBox(
                    //   height: 155.0,
                    //   child: Image.asset(
                    //     "assets/logo.jpg", // put asset logo here
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                    Text("Registration", style: style.copyWith(
                    color: Colors.black, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[Flexible(child: firstNameField),Flexible(child: lastNameField)]
                    ),
                    SizedBox(height: 5.0),
                    emailField,
                    SizedBox(height: 5.0),
                    passwordField,
                    SizedBox(
                      height: 5.0,
                    ),
                    verifyPasswordField,
                    SizedBox(
                      height: 5.0,
                    ),
                    registerButton,
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/loginpage');
                            // print("create dadto");
                          },
                          child: new Text("Have an account already?   Login now"),
                        )
                      ]),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
