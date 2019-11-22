import 'dart:async';
import 'dart:math';
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
      body: CustomPaint(
        size: Size.infinite,
        painter: GamePainter(angle: _angle),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  double angle;

  Canvas _canvas;
  Size _size;
  Paint _gamePaint = Paint()..isAntiAlias = true;
  Cube cube = Cube();

  Matrix4 camera = Matrix4.identity();

  GamePainter({this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;

    _clear();
    double fov = pi / 4;
    double aspect = size.width / size.height;
    double zn = 0.001;
    double zf = 100.0;
    double tanFov = tan(fov / 2);

    camera = Matrix4.zero();
    camera.row0 = V.Vector4((1.0 / (aspect * tanFov)), 0.0, 0.0, 0.0);
    camera.row1 = V.Vector4(0.0, 1 / tanFov, 0.0, 0.0);
    camera.row2 = V.Vector4(0.0, 0.0, -(zf + zn) / (zf - zn), -1.0);
    camera.row3 = V.Vector4(0.0, 0.0, -(2 * zf * zn) / (zf - zn), 1.0);

    /* print('///');
    print(camera);*/

    Matrix4 matrix4 = Matrix4.identity();
    matrix4.rotateX(angle);
    matrix4.rotateY(angle);
    matrix4.rotateZ(angle);
    matrix4.scale(70.0, 70.0, 70.0);
    camera.translate(size.width / 2, size.height / 4, -200.0);
    camera.multiply(matrix4);

    List<GameFace> faces = GameUtil.orderZ(cube.transform(camera.storage));
    faces.forEach((face) {
      Path path = GameUtil.generaFace(face);

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
