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
    //material app widget
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
  List _cryptoList; //store cryptolist
  final _saved = Set<Map>(); //store favorite cryptos
  final _boldStyle = new TextStyle(fontWeight: FontWeight.bold);
  bool _loading = false; //control state
  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
  ];
  //this means that the function will be executed sometime in the future (in this case does not return data)
  Future<void> getCryptoPrices() async {
    //async to use await, which suspends the current function, while it does other stuff and resumes when data ready
    print('getting crypto prices'); //print
    String _apiURL = "https://pro-api.coinmarketcap.com"; //url to get data
    http.Response response = await http.get(_apiURL); //wait for response
    setState(() {
      this._cryptoList =
          jsonDecode(response.body); //sets the state of the widget
      print(_cryptoList); //print the list
    });
    return;
  }

  //takes in object and returns the price within 2 decimals
  String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals);
    double d = double.parse(crypto['price_usd']);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  CircleAvatar _getLeadingWidget(String name, MaterialColor color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: new Text(name[0]),
    );
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

  //widget that builds the list
  Widget _buildCryptoList() {
    return ListView.builder(
        itemCount: _cryptoList.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          //item builder returns a row for each index
          //if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

          //final index = i ~/ 2; get actual index excluding dividers
          final index = i;
          print(index);
          final MaterialColor color = _colors[index %
              _colors.length]; //iterate through indexes and get the next color
          return _buildRow(_cryptoList[index], color); //build the row widget
        });
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    //if _saved contains our crypto, return true.
    final bool favorited = _saved.contains(crypto);

    //handle the heart icon tapped
    void _fav() {
      setState(() {
        if (favorited) {
          _saved.remove(crypto);
        } else {
          _saved.add(crypto);
        }
      });
    }

    //returns a row with props
    return ListTile(
      leading: _getLeadingWidget(crypto['name'], color),
      title: Text(crypto['name']),
      subtitle: Text(
        cryptoPrice(crypto),
        style: _boldStyle,
      ),
      trailing: new IconButton(
          icon: Icon(favorited ? Icons.favorite : Icons.favorite_border),
          color: favorited ? Colors.red : null,
          onPressed: _fav),
    );
  }
}
