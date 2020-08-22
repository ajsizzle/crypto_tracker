import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

//runApp calls MyApp
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price List',
      theme: new ThemeData(primaryColor: Colors.white),
      home: CryptoList(),
    );
  }
}

//create stateful widget
class CryptoList extends StatefulWidget {
  @override
  CryptoListState createState() => CryptoListState();
}

class CryptoListState extends State<CryptoList> {
  //used to view favorited cryptos
  List _cryptoList;
  //this means that the function will be executed sometime in the future (in this case does not return data)
  Future<void> getCryptoPrices() async {
    //async to use await, which suspends the current function, while it does other stuff and resumes when data ready
    print('getting crypto prices'); //print
    String _apiURL = "https://pro-api.coinmarketcap.com"; //url to get data
    http.Response response = await http.get(_apiURL); //wait for response
    setState(() {
      this._cryptoList =
          jsonDecode(response.body); //sets the state of the widget
      print(_cryptoList);
    });
    return;
  }

  @override
  void initState() {
    //override creation of state to allow calling of function
    super.initState();
    getCryptoPrices(); //this function is called which then sets the state of the app.
  }

  //build method
  @override
  Widget build(BuildContext context) {
    //Implements the basic Material Design visual layout structure.
    //This class provides APIs for showing drawers, snack bars, and bottom sheets.
    return Scaffold(
        appBar: AppBar(
          title: Text('CryptoList'),
          actions: <Widget>[
            //Used to view favorites
            new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: new Center(
          //body of the scaffold
          child: new Text('my crypto app'),
        ));
  }

  //how we save the favorite cryptos
  void _pushSaved() {}
}
