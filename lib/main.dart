import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:btc_calculator/ad_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  // runApp(MyApp());
  runApp(Provider.value(
    value: adState,
    builder: (context, child) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BTC Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '仮想通貨換算'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Map<String, String> currenciesMap = {
    'Bitcoin(BTC)' : 'btc',
    'Ethereum(ETH)' : 'eth',
    'Ethereum Classic(ETC)' : 'etc',
    'Lisk(LSK)' : 'lsk',
    'Factom(FCT)' : 'fct',
    'Ripple(XRP)' : 'xrp',
    'NEM(ZEM)' : 'zem',
    'Litecoin(LTC)' : 'ltc',
    'Bitcoin Cash(BCH)' : 'bch',
    'Monacoin(MONA)' : 'mona',
    'Stellar Lumens(XLM)' : 'xlm',
    'Qtum(QTUM)' : 'qtum',
    'Basic Attention Token(BAT)' : 'bat',
    'LOST(LOST)' : 'lost',
    'Enjin Coin(ENJ)' : 'enj',
    'OMG(OMG)' : 'omg',
  };

  String _currentCurrency = 'btc';
  String _dropdownValue = 'Bitcoin(BTC)';
  late BannerAd banner;

  // Rate params
  double _jpyRate = 0.0;
  double _btcRate = 0.0;

  // Form params
  String _fromLabel = 'BTC';

  var _fromTextController = TextEditingController();
  var _toJpyTextController = TextEditingController();
  var _toBtcTextController = TextEditingController();

  void _handleFromText(String e) {
    setState(() {
      double _fromValue = e != "" ? double.parse(e) : 0.0;
      double _toJpyValue = _fromValue * _jpyRate;
      double _toBtcValue = _fromValue * _btcRate;
      _toJpyTextController.text = _toJpyValue.toString();
      _toBtcTextController.text = _toBtcValue.toString();
    });
  }

  void _handleToJpyText(String e) {
    double _toJpyValue = e != "" ? double.parse(e) : 0.0;
    double _fromValue = _toJpyValue / _jpyRate;
    double _toBtcValue = _fromValue * _btcRate;
    setState(() {
      _fromTextController.text = _fromValue.toString();
      _toBtcTextController.text = _toBtcValue.toString();
    });
  }

  void _handleToBtcText(String e) {
    double _toBtcValue = e != "" ? double.parse(e) : 0.0;
    double _fromValue = _toBtcValue / _btcRate;
    double _toJpyValue = _fromValue * _jpyRate;
    setState(() {
      _fromTextController.text = _fromValue.toString();
      _toJpyTextController.text = _toJpyValue.toString();
    });
  }

  Future getRate(String currency) async {
    final jpyResponse = await http.get(Uri.https('coincheck.com', 'api/rate/${currency}_jpy'));
    final btcResponse = await http.get(Uri.https('coincheck.com', 'api/rate/${currency}_btc'));

    if (jpyResponse.statusCode == 200 && btcResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map jpyData = jsonDecode(jpyResponse.body);
      Map btcData = jsonDecode(btcResponse.body);

      setState(() {
        _jpyRate = double.parse(jpyData["rate"]);
        _btcRate = currency == 'btc' ? 1.0 : double.parse(btcData["rate"]);
      });
      _setTextField(currency);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void _changeCurrency(String currency) {
    setState(() {
      _currentCurrency = currency;
      _fromLabel = _currentCurrency.toUpperCase();
      getRate(currency);
    });
  }

  void _setTextField(String currency) {
    _fromTextController.text = "1.0";
    _toJpyTextController.text = _jpyRate.toString();
    _toBtcTextController.text = _btcRate.toString();
  }

  @override
  void initState() {
    super.initState();
    getRate(_currentCurrency);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((status) {
      setState(() {
        banner = BannerAd(
          adUnitId: adState.bannerAdUnitId,
          size: AdSize.banner,
          request: AdRequest(),
          listener: adState.adListener,
        )
          ..load();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title!),
      ),
      body: Container(
        // color: Colors.grey,
        child: Column(
          children: <Widget>[
            Container(
              // color: Colors.yellow,
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        // color: Colors.red,
                        margin: EdgeInsets.only(right: 10.0, left: 10.0),
                        child: DropdownButton<String>(
                          value: _dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple, fontSize: 18),
                          underline: Container(
                            height: 1,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _dropdownValue = newValue!;
                              _currentCurrency = currenciesMap[_dropdownValue]!;
                            });
                            _changeCurrency(_currentCurrency);
                          },
                          items: <String>['Bitcoin(BTC)', 'Ethereum(ETH)', 'Ethereum Classic(ETC)', 'Lisk(LSK)', 'Factom(FCT)', 'Ripple(XRP)', 'NEM(ZEM)', 'Litecoin(LTC)', 'Bitcoin Cash(BCH)', 'Monacoin(MONA)', 'Stellar Lumens(XLM)', 'Qtum(QTUM)', 'Basic Attention Token(BAT)', 'LOST(LOST)', 'Enjin Coin(ENJ)', 'OMG(OMG)']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        // color: Colors.red,
                        padding: EdgeInsets.only(right: 3.0, left: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(_jpyRate.toString(), style: TextStyle(fontSize: 18),),
                          ],
                        ),
                      ),
                      Container(
                        // color: Colors.blue,
                        // padding: EdgeInsets.only(right: 10.0, left: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text('JPY', style: TextStyle(fontSize: 14, color: Colors.grey),),
                          ],
                        ),
                      ),
                      if (_currentCurrency != 'btc') Container(
                        // color: Colors.red,
                        padding: EdgeInsets.only(right: 3.0, left: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(_btcRate.toString(), style: TextStyle(fontSize: 18),),
                          ],
                        ),
                      ),
                      if (_currentCurrency != 'btc') Container(
                        // color: Colors.blue,
                        // padding: EdgeInsets.only(right: 10.0, left: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text('BTC', style: TextStyle(fontSize: 14, color: Colors.grey),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.yellow,
              // height: 100,
              padding: EdgeInsets.only(right: 10.0, left: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: TextField(
                      controller: _fromTextController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.0',
                        labelText: _fromLabel,
                      ),
                      onChanged: _handleFromText,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: TextField(
                      controller: _toJpyTextController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.0',
                        labelText: 'JPY',
                      ),
                      onChanged: _handleToJpyText,
                    ),
                  ),
                  if (_currentCurrency != 'btc') Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: TextField(
                        controller: _toBtcTextController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.0',
                          labelText: 'BTC',
                        ),
                        onChanged: _handleToBtcText,
                      ),
                    ),
                ],
              ),
            ),
            if (banner == null)
              SizedBox(height: 50) // Ads
            else
              Container(
                height: 50,
                child: AdWidget(ad: banner),
              ),
          ],
        ),
      ),
    );
  }
}
