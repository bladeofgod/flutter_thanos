/*
* Author : LiJiqqi
* Date : 2020/4/13
*/


import 'package:flutter/material.dart';

class SandableWidget extends StatefulWidget{

  Widget child;
  //吹散时间
  final Duration duration;
  // 图层数量  图层越多，吹散效果越好但是更耗时
  final int numberOfLayers;


  SandableWidget(this.child,{this.duration = const Duration(seconds: 3),
        this.numberOfLayers = 10});

  @override
  State<StatefulWidget> createState() {

    return SandableWidgetState();
  }

}

class SandableWidgetState extends State<SandableWidget> with TickerProviderStateMixin{

  AnimationController _mainController;

  GlobalKey _globalKey = GlobalKey();

  List<Widget> layers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mainController = AnimationController(vsync: this,duration: widget.duration);
  }
  @override
  void dispose() {
    _mainController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: <Widget>[
        ...layers,//沙化涂层
        GestureDetector(
          onTap: (){},
          child: _mainController.isAnimating?
              Container():RepaintBoundary(
            key: _globalKey,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

















