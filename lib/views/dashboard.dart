import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocation/geolocation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/sms.dart';

import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _DashboardState createState() => _DashboardState();
  
}

  List texts_holder=["Fire","Flood","Car","Stranded","Hostage","Others"];
  List texts=["https://www.pngkit.com/png/detail/78-788100_fire-logo-png-svg-free-download-fire-logo.png",
  "https://thumbs.dreamstime.com/b/home-flood-insurance-line-icon-flooded-house-linear-style-sign-mobile-concept-web-design-property-outline-vector-symbol-150717869.jpg",
  "https://www.clipartkey.com/mpngs/m/33-331356_car-logo-clipart-black-and-white-car-crash.png",
  "https://images.squarespace-cdn.com/content/v1/50ec4fa1e4b0481f98a71d8c/1358275409985-ISVV1W07XEMA8ROUR0BV/ke17ZwdGBToddI8pDm48kOqPJtvjjuG3_ml6uLkN2WtZw-zPPgdn4jUwVcJE1ZvWQUxwkmyExglNqGp0IvTJZamWLI2zvYWH8K3-s_4yszcp2ryTI0HqTOaaUohrI8PIghci9KhIgCQVrXTOjKXt-W8lkGjPH-kug2ICA9ybEHMKMshLAGzx4R3EDFOm1kBS/AK_SS_stranded_logo.jpg?format=1500w",
  "https://4c448342d6996fb20913-fd1f9dc15ff616aa7fa94219cb721c9c.ssl.cf3.rackcdn.com/64/5d/50127_1da692ac36ae4d53b2ceb6411a1241ca.jpg",
  "https://www.shop.accurator.asia/image/accurator/image/data/Logo/Accurator%20Others%20Logo.png"];
  // List images=[];
  
  var name;

  
class CustomWidget extends StatelessWidget {
  CustomWidget(this._index) {
    debugPrint('initialize: $_index');
  }


  final int _index;
  
  bool _canConnectServer = false;

   Widget _smsSent(BuildContext context) {
  return new AlertDialog(
    title: Text("SMS Succesfully Delivered"),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Your report has been sent, please wait for the rescuers."),
      ],
    ),
    actions: <Widget>[
      TextButton(onPressed: () {
        Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
      }, child: Text("Proceed"))
    ] ); }

  Widget _serverConnectionError(BuildContext context) {
  return new AlertDialog(
    title: Text("Can't connect to the server!"),
    content: new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Can't seem to connect to the server"),
      ],
    ),
    actions: <Widget>[
      TextButton(
        child: Text("Try again"),
        onPressed: ()  {
          Navigator.pop(context);
        } ),
        TextButton(onPressed: () async {
          print("Final = " + _canConnectServer.toString());
          StreamSubscription<LocationResult> subscription = Geolocation.currentLocation(accuracy: LocationAccuracy.best).listen((result) async {
            print(result.locations);
            if(result.isSuccessful) {

              double latitude = result.location.latitude;
              double longitude = result.location.longitude;

              print("lat: " + latitude.toString());
              print("long: " + longitude.toString());

              List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);


              SmsSender sender = new SmsSender();
              String address = "09750458576";
              String formatMsg;

              formatMsg = "From: " + name + 
              "\nType: " + texts_holder.elementAt(_index) +
              "\nLocation: " + placemarks.first.locality + 
              "\nLatitude: " + latitude.toString() + 
              "\nLongitude: " + longitude.toString() +
              "\nhttps://www.google.com/maps/search/"+latitude.toString()+","+longitude.toString();
              print(formatMsg);
              SmsMessage message = new SmsMessage(address, formatMsg);
              message.onStateChanged.listen((state) {
                if (state == SmsMessageState.Sent) {
                  print("SMS is sent!");
                } else if (state == SmsMessageState.Delivered) {
                  print("SMS is delivered!");
                   showDialog(
                  context: context,
                  builder: (BuildContext context) =>_smsSent(context));
                }
              });
              sender.sendSms(message);
            }
          });
        }, child: Text("Use SMS instead") )
         ]);
    }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 200,
        color: Colors.white,
        child: Center(child: Image.network(texts.elementAt(_index))),
      ),
      onTap: () async {
        print(texts_holder.elementAt(_index));

        final ping = Ping('192.168.1.4', count: 3);


        // Begin ping process and listen for output
        ping.stream.listen((event) async {
          try {
             if (event.response.ttl != null) {
            _canConnectServer = true;
            await ping.stop();
            print("Got connection");
          }
          print(event.response.ttl);
          } catch (e){
            print("safe");
          }
         
        });

        // Waiting for ping to output first two results
        // Not needed in actual use. For example only
        await Future.delayed(Duration(seconds: 3));


        if (_canConnectServer) {
          print("Can connect to server");

          StreamSubscription<LocationResult> subscription = Geolocation.currentLocation(accuracy: LocationAccuracy.best).listen((result) async {
            print(result.locations);
            if(result.isSuccessful) {

              double latitude = result.location.latitude;
              double longitude = result.location.longitude;

              print("lat: " + latitude.toString());
              print("long: " + longitude.toString());

              List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);


          Map dataSend = {
                  "longitude" : longitude.toString(),
                  "latitude" : latitude.toString(),
                  "resident_ID" : "1",
                  "action" : "report"
                };


                final response = await http.post(
                Uri.http('192.168.1.4', 'tabang/event.php'),
                body: dataSend);

                print(response.body);
                _canConnectServer = false;
            } 
            
            }
            );

        } else {
          showDialog(
                  context: context,
                  builder: (BuildContext context) =>_serverConnectionError(context));
        }
        // Stop the ping prematurely and output a summary

        
       


      }
    );
  }
}
class _DashboardState extends State<Dashboard> {

  
  SharedPreferences prefs ;

  _DashboardState() {
    _getName().then((value) => setState(() {
          name = value;
        }));
  }

 Future<String> _getName() async {
   prefs = await SharedPreferences.getInstance();
   
   return prefs.getString('email');
 }

  

  @override
        //  return Scaffold(
        //    appBar: AppBar(
        //               title: Text("Tabang Dashboard"),
                      
        //                   ),
        //   body: Center(
        //     child: MaterialButton(
        //     minWidth: MediaQuery.of(context).size.width,
        //     padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        //     onPressed: () async {
        //       SharedPreferences prefs = await SharedPreferences.getInstance();
        //       prefs.clear();
        //       Navigator.pushReplacementNamed(context, '/loginpage');
        //     },
        //     child: Column(children: <Widget>[
        //         Text("Logout",
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //             color: Colors.black, fontWeight: FontWeight.bold),),
        //             Text("Gwapo")]),
        //   ),
        // ));
  Widget build(BuildContext context) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                  SliverAppBar(floating: true,
                    pinned: true,
                    expandedHeight: 150.0,
                    flexibleSpace: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: FlexibleSpaceBar(
                                title: Text('Tabang Dashboard',style: TextStyle(color: Colors.white),),
                          )
                        ),
                      ]
                    ),
                  ),
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisSpacing: 100.0,
                      crossAxisSpacing: 20.0,
                      childAspectRatio: 1.2,
                    ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CustomWidget(index),
                    childCount: texts.length,
                  )),
              ]
            )
          ),
          endDrawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: new IconButton(
                      padding: new EdgeInsets.all(0.0),
                      icon: new Icon(Icons.person, size: 100.0),
                      onPressed: (){}),
                  ),
                Text(name),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.clear();
                    Navigator.pushReplacementNamed(context, '/loginpage');
                  },
                ),
              ],
            )
          ),
        );
      }
    }

    
