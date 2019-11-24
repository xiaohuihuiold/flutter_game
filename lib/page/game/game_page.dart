import 'dart:async';
import 'dart:math';
import 'package:flutter_game/common/game/camera.dart';
import 'package:vector_math/vector_math_64.dart' as V;

import 'package:flutter/material.dart';
import 'package:flutter_game/common/game/game_object.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  Timer _timer;
  double _angle = 0.0;

  Camera _camera = Camera();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 1), (_) {
      setState(() {
        _angle += 0.001;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onPanUpdate: (detail) {
              _camera.updateMouse(detail.delta.dx, detail.delta.dy);
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: GamePainter(
                angle: _angle,
                camera: _camera,
              ),
            ),
          ),
          Positioned(
            left: 50.0,
            bottom: 50.0,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //_camera.toFront();
                    _camera.updateMouse(0.0, 1.0);
                  },
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white54),
                    child: Text('W'),
                  ),
                ),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        _camera.toLeft();
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white54),
                        child: Text('A'),
                      ),
                    ),
                    SizedBox(width: 50.0),
                    GestureDetector(
                      onTap: () {
                        _camera.toRight();
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white54),
                        child: Text('D'),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    _camera.toBack();
                  },
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white54),
                    child: Text('S'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  double angle;
  Camera camera;

  Canvas _canvas;
  Size _size;
  Paint _gamePaint = Paint()..isAntiAlias = true;
  Cube cube = Cube();

  GamePainter({
    this.camera,
    this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;
    if (camera == null) {
      return;
    }
    camera.update();
    camera.updateSize(_size);

    _clear();

    Matrix4 view = Matrix4.identity();
    view.translate(0.0, 0.0, 60.0);
    view.rotateX(angle);
    view.rotateZ(angle);

    List<GameFace> faces = List();
    for (int w = 0; w < 10; w += 2) {
      for (int h = 0; h < 10; h += 2) {
        Matrix4 model = Matrix4.identity();
        model.translate(0.0 + w - 5.0, 0.0 + h - 5.0, 0.0);
        //model.rotateX(angle);
        //model.rotateY(angle);
        //model.rotateZ(angle);
        faces
            .addAll(cube.transform((camera.projection * view * model).storage));
      }
    }
    faces = GameUtil.orderZ(faces);
    faces.forEach((face) {
      Path path = GameUtil.generaFace(face, _size);
      _canvas.drawPath(
        path,
        _gamePaint
          ..style = PaintingStyle.fill
          ..color = face.color ?? Colors.transparent,
      );
    });
  }

  void _clear() {
    _canvas.drawColor(Colors.black, BlendMode.srcOver);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
