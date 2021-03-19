import 'package:flutter/material.dart';
import 'views/authentication/login.dart';
import 'views/authentication/register.dart';
import 'views/dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: MyHomePage(title: 'Flutter Demo Home Page'),
    // );

    return MaterialApp(
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/loginpage',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/loginpage': (context) => LoginPage(title: 'Tabang'),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/registerpage': (context) => RegisterPage(),
        '/dashboard': (context) => Dashboard()
      },
    );
  }
}
