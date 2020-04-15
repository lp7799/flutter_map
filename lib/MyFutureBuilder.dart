
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


///自定义网络加载状态和网络请求
class MyFutureBuilder extends StatefulWidget {
  /// Future to resolve.
  final Future future;
  /// Whether or not the future result should be stored.
  final bool rememberFutureResult;
  /// 连接到异步计算时显示的小部件。
  final Widget whenActive;
  /// 在连接到异步计算并等待交互时显示的小部件。
  final Widget whenWaiting;
  /// 未连接到n个异步计算时显示的小部件。
  final Widget whenNone;
  /// 在尚未完成异步计算时显示的小部件。
  final Widget whenNotDone;
  ///  异步计算完成后要调用的函数。
  final Widget Function(dynamic snapshotData) whenDone;
  /// 在非空[future]完成之前将使用的数据。
  ///
  /// 有关更多信息，请参见[FutureBuilder]
  final dynamic initialData;
  ///需要特殊错误错误处理
  final Widget hasError;
  const MyFutureBuilder({
    Key key,
    @required this.future,
    @required this.rememberFutureResult,
    @required this.whenDone,
    this.whenActive,
    this.whenNotDone,
    this.whenNone,
    this.whenWaiting,
    this.hasError,
    this.initialData
  }) :
        assert(future != null),
        assert(rememberFutureResult != null),
        assert(whenDone != null),
        super(key: key);

  @override
  _MyFutureBuilderState createState() => _MyFutureBuilderState();
}

class _MyFutureBuilderState extends State<MyFutureBuilder> {

  var _cachedFuture;

  @override
  void initState() {
    super.initState();
    _cachedFuture = this.widget.future;

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.widget.rememberFutureResult ? _cachedFuture : this.widget.future,
      initialData: this.widget.initialData,
      builder: (BuildContext context, snapshot) {
        switch(snapshot.connectionState){
          case ConnectionState.active:
            if(widget.whenActive !=null){
              print("--widget--active--");
              return widget.whenActive;
            }else{
              print("----active--");
              return Container();
            }

            break;
          case ConnectionState.waiting:
            if(widget.whenWaiting != null){
              return widget.whenWaiting;
            }else{
              return Center(child: CupertinoActivityIndicator());
            }
            break;
          case ConnectionState.none:
            if(widget.whenNone != null){
              print("--widget--whenNone--");
              return widget.whenNone;
            }else{
              print("----whenNone--");
              return Container();
            }
            break;
          case ConnectionState.done:
            if(snapshot.hasError) {
              if(widget.hasError != null){
                return widget.hasError;
              }else{
                return Center(child: Column(
                  children: <Widget>[
                    Image.asset("images/net_error",width: 48,height: 48,fit: BoxFit.cover,),
                    Text("网络错误",style: TextStyle(color: Colors.black,fontSize: 16),),
                  ],
                ));
              }
            }
            return widget.whenDone(snapshot.data);
            break;
          default:
            return Center(child: Text("未知错误，请联系客服"),);
        }

      },
    );
  }
}