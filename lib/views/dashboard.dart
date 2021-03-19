import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List texts=["Jay","Jones","Anet","etorma","jabla","alim"];
  
class CustomWidget extends StatelessWidget {
  CustomWidget(this._index) {
    debugPrint('initialize: $_index');
  }


  final int _index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 200,
        color: (_index % 2 != 0) ? Colors.white : Colors.grey,
        child: Center(child: Text(texts.elementAt(_index), style: TextStyle(fontSize: 40))),
      ),
      onTap: (){
        print(texts.elementAt(_index));
      },
    );
  }
}
class _DashboardState extends State<Dashboard> {

  
  SharedPreferences prefs ;
  var name;

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
                                title: Text('Tabang Dashboard',style: TextStyle(color: Colors.black),),
                          )
                        ),
                      ]
                    ),
                  ),
                  SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CustomWidget(index),
                    childCount: texts.length,
                  )),
              ]
            )
          ),
          endDrawer: Drawer(
            child: Column(
              children: [
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

    
