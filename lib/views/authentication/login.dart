import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocation/geolocation.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  SharedPreferences prefs;
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool rememberMe = false;
  var myLoc = "Can not detect";
  // var url = "";


  Widget _showLocation(BuildContext context) {
  return new AlertDialog(
    title: Text("Your location is"),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(myLoc),
      ],
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: ()  {
          Navigator.popUntil(context, ModalRoute.withName('/loginpage'));
          // launch(url);
        },
        textColor: Theme.of(context).primaryColor,
        child: Text("Close"),
      ),
    ],
  );
    }

  Widget _buildPopupDialog(BuildContext context, String title, String body, String buttonText) {
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
        onPressed: () async {
          if (buttonText != "Try again!") {
            Geolocation.enableLocationServices().then((result) {
      // Request location
          print(result);
    
            StreamSubscription<LocationResult> subscription = Geolocation.currentLocation(accuracy: LocationAccuracy.best).listen((result) async {
              print(result.locations);
              if(result.isSuccessful) {
                
                prefs = await SharedPreferences.getInstance();
                double latitude = result.location.latitude;
                double longitude = result.location.longitude;
                
                print("lat: " + latitude.toString());
                print("long: " + longitude.toString());
                
                List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
                print(placemarks.first.locality.toString());
                print(placemarks.first.locality.toString().contains('Cagayan'));
                if (placemarks.first.locality.toString().contains('Cagayan')) {
                  if (!prefs.containsKey("email")){
                      prefs.setString("email", emailController.text);
                    }
                    
                    Navigator.popUntil(context, ModalRoute.withName('/loginpage'));
                    Navigator.pushReplacementNamed(context, '/dashboard');
                } else {
                  // setState(() {
                  //   myLoc = placemarks.first.name + " | " + placemarks.first.locality + "|" + latitude.toString() + " : " + longitude.toString();
                  //   myLoc += "\nYou are NOT IN Cagayan, you are NOT permitted to use the app."+prefs.getString("email");
                  //     });
                    setState(() {
                      myLoc = "Not In Cagayan, Can't log you in";
                    });
                      showDialog(
                      context: context,
                      builder: (BuildContext context) =>_showLocation(context));
                  }

                
                // final coordinates = new Coordinates(latitude, longitude);
                // var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
                // var first = addresses.first;
                // if (first.addressLine.toString().contains('Cagayan')) {
                //   print("Cagayn De Oro Detected");
                //   print(first.addressLine.toString());
                // }else {
                //   print(first.toString());
                // }
              } else {
                print("cant");
              }
            });}).catchError((e) {
      // Location Services Enablind Cancelled
    });

          } else {
            Navigator.pop(context);
          }
        },
        textColor: Theme.of(context).primaryColor,
        child: Text(buttonText),
      ),
    ],
  );
    }

  void _onRememberMeChanged(bool newValue) => setState(() {
    rememberMe = newValue;

    if (rememberMe) {
      print(rememberMe);
    } else {
      print(rememberMe);
    }
  });

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
        final loginButon = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xFFD32F2F),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () async {
              print(emailController.text);
              print(passwordController.text);
              prefs = await SharedPreferences.getInstance();
              if (emailController.text == "test" || emailController.text == "admin") {
                print("test sya");
                
                
                
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>_buildPopupDialog(context,"Login Successfully","Checking your location","Proceed"));
              } else {
                Map dataSend = {
                  "emailAddress": emailController.text,
                  "password": passwordController.text,
                  "action": "login"
                };


                final response = await http.post(
                Uri.http('192.168.0.127', 'tabang/event.php'),
                body: dataSend);

                print(response.body);

                //DONE 3-9-2021
                try {
                  if(int.parse(response.body) == 0) {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) =>_buildPopupDialog(context,"Login Failed","Incorrect user and password","Try again!"));
                  }
                } on Exception catch (_) {
                  showDialog(
                  context: context,
                  builder: (BuildContext context) =>_buildPopupDialog(context,"Login Successfully","Successfully logged in","Proceed"));
                }
              }
                
              print("TEST RUN");
            },
            child: Text("Login",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );

        final clearButton = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Color(0xFFD32F2F),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () async {
              prefs = await SharedPreferences.getInstance().whenComplete(() => {
              prefs.clear()});


              Navigator.pushReplacementNamed(context, '/loginpage');
            },
            child: Text("Logout",
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );

        Future<String> _getLog = Future<String>.delayed(
          Duration(seconds: 0),
          () async {
            prefs = await SharedPreferences.getInstance();
            if (prefs.containsKey('email')) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else {
              return prefs.getString('email');
            }
          },
        );

         return Scaffold(
          body: Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: 
                    FutureBuilder<String>(
        future: _getLog,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          List<Widget> test ;
          if (snapshot.hasData) {
            // test = [Padding(
            //     padding: const EdgeInsets.only(top: 16),
            //     child: Text('Logged in: ${snapshot.data}'),
            //   ),
            //         clearButton,];
            // Navigator.pushReplacementNamed(context, '/dashboard');
            
          } else if (snapshot.hasError) {
            test = [Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )];
          } else {
            test = [Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('No data logged in.'),
              ),SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/logo.jpg", // put asset logo here
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text("TABANG", style: style.copyWith(
                    color: Colors.black, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15.0),
                    emailField,
                    SizedBox(height: 15.0),
                    passwordField,
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Checkbox(
                              checkColor: Color(0xFFD32F2F),
                              activeColor: Colors.grey,
                              value: rememberMe,
                              onChanged: _onRememberMeChanged
                            ),
                            Text("Remember Me"),
                          ]),
                          Row(
                          children: <Widget>[
                            Text("Forgot Password"),
                          ]),
                      ],
                    ),
                    loginButon,
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/registerpage');
                            // print("create dadto");
                          },
                          child: new Text("Don't have an account?   Create Now"),
                        )
                      ]),];
          }
          return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: test
            );
        }),
              ),
            ),
          ),
        );
      }
    }
