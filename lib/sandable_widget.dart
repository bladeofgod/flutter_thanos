/*
* Author : LiJiqqi
* Date : 2020/4/13
*/


import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:image/image.dart' as image;

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
          onTap: (){
            blow();
          },
          child: _mainController.isAnimating?
              Container():RepaintBoundary(
            key: _globalKey,
            child: widget.child,
          ),
        ),
      ],
    );
  }

  Future<void> blow()async{
    //获取完整的图像
    image.Image fullImage = await _getImageFromWidget();

    int width = fullImage.width;
    int height = fullImage.height;

    // 初始化与原图相同大小的空白的图层
    List<image.Image> blankLayers = List.generate(widget.numberOfLayers, (i)=>image.Image(width,height));
    // 将原图的像素点，分布到layer中
    separatePixels(blankLayers,fullImage,width,height);

    // 将图层转换为Widget
    layers = blankLayers.map((layer)=> imageToWidget(layer)).toList();
    setState(() {

    });

    _mainController.forward();


  }

  void separatePixels(List<image.Image> blankLayers,image.Image fullImage,int width,int height){
    //遍历所有像素点
    for(int x=0;x<width;x++){
      for(int y = 0;y<height;y++){
        //获取当前像素点
        int pixel = fullImage.getPixel(x, y);
        //不考虑透明
        if(pixel == 0) continue;
        //随机生成放入的图层index
        int index = Random().nextInt(widget.numberOfLayers);
        blankLayers[index].setPixel(x, y, pixel);
      }
    }
  }

  // 将一个Widget转为image.Image对象
  Future<image.Image> _getImageFromWidget()async{
    ///需要图像化的widget
    RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();

    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();
    return image.decodeImage(pngBytes);
  }

  Widget imageToWidget(image.Image png){
    Uint8List data = Uint8List.fromList(image.encodePng(png));

    // 定义一个先快后慢的动画过程曲线
    CurvedAnimation animation = CurvedAnimation(
      parent: _mainController,curve: Interval(0,1,curve: Curves.easeOut)
    );

    // 定义位移变化的插值（始末偏移量）
    Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
        // 基础偏移量+随机偏移量
      end: Offset(20,20) +
          Offset(30,30).scale((Random().nextDouble() - 0.5) * 2,
              (Random().nextDouble() - 0.5) * 2)
    ).animate(animation);

    return AnimatedBuilder(
      animation: _mainController,
      child: Image.memory(data),
      builder: (ctx,child){
        return Transform.translate(offset: offsetAnimation.value,
          child: Opacity(
            opacity: cos(animation.value * pi / 2), // 1=>0
            child: child,
          ),);
      },
    );

  }

}

















