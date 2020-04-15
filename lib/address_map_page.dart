import 'package:amap_all_fluttify/amap_all_fluttify.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterapp/MyFutureBuilder.dart';
import 'package:flutterapp/tool.dart';
import 'package:oktoast/oktoast.dart';


class AddressMapPage extends StatefulWidget {
  @override
  _AddressMapPageState createState() => _AddressMapPageState();
}

//自定义marker点图标图片路径
final _imgUri = Uri.parse('images/position.png');

class _AddressMapPageState extends State<AddressMapPage> {
  Location _location;//进入地图当前定位
  Poi _poi; //选择的当前点位
  String search = '';//搜索关键词
  Future<List<Poi>> futurePoi;//poi点位信息
  AmapController _controller;//地图控制按钮
  Marker _marker;//添加点位 还有一些没处理好

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futurePoi = getLocation();
  }

  Future<List<Poi>> getLocation() async {
    return AmapLocation.fetchLocation(
      needAddress: true, //详细地址
    ).then((l) {
      setState(() {
        _location = l;
      });
      return _location;
    }).then((l1) {
      return getPoi(
          latLng: l1.latLng, keyword: '汽车', city: l1.city, radius: 10000);
    });
  }

  ///首次进来定位搜索
  Future<List<Poi>> getPoi(
      {LatLng latLng, String keyword, String city, int radius = 5000}) async {
    final poi = await AmapSearch.searchAround(latLng,//按照这个中心点位进行搜索
        keyword: keyword, city: _location.city, radius: radius);
    return poi;
  }
  ///点位item
  poiItems(Poi poi) {
    return RadioListTile<Poi>(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyFutureBuilder(//自定义的future方便点
                future: poi.address,
                rememberFutureResult: true,
                whenDone: (data) {
                  return Text(
                    '$data',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16),
                  );
                }),
            MyFutureBuilder(
                future: poi.title,
                rememberFutureResult: true,
                whenDone: (title) {
                  return MyFutureBuilder(
                      future: poi.distance,
                      rememberFutureResult: true,
                      whenDone: (distance) {
                        return Text(
                          '${distance}m|$title',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14),
                        );
                      });
                }),
          ],
        ),
        isThreeLine: false,
        value: poi,
        groupValue: _poi,
        onChanged: (v) {
          setState(() {
            _poi = v;
          });
        });
  }
  ///点位进行搜索
  ///1 先进行模糊点位搜索
  ///2 在拿到模糊点位的中心点进行搜索
  searchButton() async {
    _marker?.remove();//清除原来点位
    final k = await AmapSearch.searchKeyword(search, city: _location.city);
    LatLng l = await k.first.latLng;
    futurePoi = getPoi(
      latLng: l,
      keyword: search,
    );
    await _controller.setCenterCoordinate(l.latitude, l.longitude,
        zoomLevel: 16);
    _marker = await _controller.addMarker(MarkerOption(
        latLng: l,
        widget: Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 26,
        ),
        draggable: false,
        imageConfig: createLocalImageConfiguration(context),
        snippet: await k.first.address,
        visible: true,
        width: 30,
        height: 30,
        title: await k.first.title));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    AmapView(
                      // 地图类型 (可选)
                      mapType: MapType.Standard,
                      // 是否显示缩放控件 (可选)
                      showZoomControl: false,
                      // 是否显示指南针控件 (可选)
                      showCompass: false,
                      // 是否显示比例尺控件 (可选)
                      showScaleControl: true,
                      // 是否使能缩放手势 (可选)
                      zoomGesturesEnabled: true,
                      // 是否使能滚动手势 (可选)
                      scrollGesturesEnabled: true,
                      // 是否使能旋转手势 (可选)
                      rotateGestureEnabled: true,
                      // 是否使能倾斜手势 (可选)
                      tiltGestureEnabled: true,
                      // 缩放级别 (可选)
                      zoomLevel: 16,
                      onMapMoveEnd: (MapMove drag) async {
                        futurePoi = getPoi(
                            latLng: drag.latLng,
                            keyword: '',
                            city: _location.city);
                        setState(() {});
                      },
                      // 地图创建完成回调 (可选)
                      onMapCreated: (controller) async {
                        _controller = controller;

                        if (await requestPermission()) {
                          await controller.setZoomByCenter(true);
                          //await controller.showLocateControl(true);   //不能控制位置只能自己做个还原位置
                          await controller.showMyLocation(MyLocationOption(
                              myLocationType: MyLocationType.Locate));
                        }
                      },
                    ),
                    Image.asset(
                      "images/position.png",
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                        right: 12,
                        bottom: 12,
                        child: IconButton(icon: Icon(Icons.location_searching,color: Colors.blue,), onPressed: (){
                          _controller?.showMyLocation(MyLocationOption(show: true));
                        }))
                  ],
                ),
              ),
              Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8)),
                          child: TextField(

                            style: TextStyle(
                                color: Colors.white,
                                textBaseline: TextBaseline.alphabetic),
                            onChanged: (s) {
                              setState(() {
                                search = s;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: '搜索地点',
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.only(left: 8,bottom: 12),
                                hintStyle:
                                TextStyle(
                                  color: Colors.white,
                                  fontSize:
                               14,
                                ),
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.search,
                                      size: 21,
                                      color: Colors.white,
                                    ),
                                    onPressed:searchButton)),
                          ),
                        ),
                        Expanded(
                            child: MyFutureBuilder(
                          future: futurePoi,
                          rememberFutureResult: false,
                          whenDone: (data) {
                            final List<Poi> pois = data;
                            return ListView.builder(
                                itemCount: pois.length,
                                itemBuilder: (context, index) =>
                                    poiItems(pois[index]));
                          },
                        ))
                      ],
                    ),
                  ))
            ],
          ),
          appBar(context),
        ],
      ),
    );
  }

  Positioned appBar(BuildContext context) {
    return Positioned(
      top: kToolbarHeight,
      left: 12,
      right: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '取消',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 18),
              )),
          SizedBox(
            width: 60,
            child: RaisedButton(
              onPressed: ()async {
                showToast("当前选择的点位是${await _poi.address} 经纬度[${await _poi.latLng}]");
              },
              color: Colors.blueAccent,
              child: Text(
                '确定',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
