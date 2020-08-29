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
  List _cryptoList = []; //store cryptolist
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
    List cryptoDatas = [];

    print('getting crypto prices'); //print
    String _apiURL =
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15"; //url to get data
    setState(() {
      this._loading = true;
    });
    http.Response response = await http.get(_apiURL, headers: {
      "X-CMC_PRO_API_KEY": "7fcdada1-6ef8-4c7f-b199-bb7868d2c97f"
    }); //wait for response

    Map<String, dynamic> responseJSON = json.decode(response.body);
    if (responseJSON["status"]["error_code"] == 0) {
      for (int i = 1; i <= responseJSON["data"].length; i++) {
        cryptoDatas.add(responseJSON["data"][i.toString()]);
      }
    }
    print(cryptoDatas);

    setState(() {
      this._cryptoList = cryptoDatas;
      this._loading = false;
    });
    return;
  }

  //takes in object and returns the price within 2 decimals
  String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals);
    double d = (crypto['quote']['USD']['price']);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  CircleAvatar _getLeadingWidget(String name, MaterialColor color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: new Text(name[0]),
    );
  }

  _getMainBody() {
    if (_loading) {
      //return progress indicator if it is loading
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new RefreshIndicator(
        child: _buildCryptoList(),
        onRefresh: getCryptoPrices,
      );
    }
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
        body: _getMainBody());
  }

  //how we save the favorite cryptos
  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (crypto) {
              return new ListTile(
                leading: _getLeadingWidget(crypto['name'], Colors.blue),
                title: Text(crypto['name']),
                subtitle: Text(
                  cryptoPrice(crypto),
                  style: _boldStyle,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved Cryptos'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

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
