import 'package:amap_all_fluttify/amap_all_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/address_map_page.dart';
import 'package:flutterapp/tool.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: OKToast(dismissOtherOnShow: true, child: MyHomePage('地图选点')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage(this.title);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMap();
  }

  initMap() async {
    if (await requestPermission()) {
      await AmapService.init(
        iosKey: '暂时没得',
        androidKey: '6e67b07437d4f7e20453b442b9ff6b11',
      );
    } else {
      showToast('当前没获取地图权限');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddressMapPage())),
          child: Text('地图选点'),
        ),
      ),
    );
  }
}
