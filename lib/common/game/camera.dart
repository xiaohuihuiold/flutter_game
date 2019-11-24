import 'dart:math';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

import 'package:flutter_game/common/util/game_util.dart';

class Camera {
  double speed = 0.1;
  double sensitivity = 0.1;
  Size size = Size(1920, 1080);

  double pitch = 0.0;
  double yaw = 0.0;

  Matrix4 view = Matrix4.identity();
  Matrix4 projection = Matrix4.identity();
  Vector3 position = Vector3(0.0, 0.0, 3.0);
  Vector3 front = Vector3(0.0, 0.0, -1.0);
  Vector3 up = Vector3(0.0, 1.0, 0.0);

  Camera();

  Camera.fromSize(Size size) {
    update();
    updateSize(size);
  }

  void toFront() {
    position += front.normalized() * speed;
    update();
  }

  void toBack() {
    position -= front.normalized() * speed;
    update();
  }

  void toLeft() {
    Vector3 left = front.cross(up).normalized();
    position -= left * speed;
    update();
  }

  void toRight() {
    Vector3 left = front.cross(up).normalized();
    position += left * speed;
    update();
  }

  void update() {
    view = _lookAt(position, position + front, up);
    /*print('///');
    print(view);*/
  }

  void updateProjection() {
    projection = _perspective(
        GameUtil.radians(45.0), size.width / size.height, 0.1, 100.0);
  }

  void updateSize(Size size) {
    this.size = size;
    updateProjection();
  }

  void updateMouse(double deltaX, double deltaY) {
    yaw += deltaX * sensitivity;
    pitch += deltaY * sensitivity;
    if (pitch > 89.0) pitch = 89.0;
    if (pitch < -89.0) pitch = -89.0;
    updateFront();
  }

  void updateFront() {
    front.x = cos(GameUtil.radians(pitch)) * cos(GameUtil.radians(yaw));
    front.y = sin(GameUtil.radians(pitch));
    front.z = cos(GameUtil.radians(pitch)) * sin(GameUtil.radians(yaw));
    update();
  }

  Matrix4 _lookAt(Vector3 eye, Vector3 center, Vector3 up) {
    Vector3 f = (center - eye).normalized();
    Vector3 s = f.cross(up).normalized();
    Vector3 u = s.cross(f);

    Matrix4 result = Matrix4.identity();
    result.row0 = Vector4(s.x, u.x, -f.x, 0.0);
    result.row1 = Vector4(s.y, u.y, -f.y, 0.0);
    result.row2 = Vector4(s.z, u.z, -f.z, 0.0);
    result.row3 = Vector4(-s.dot(eye), -u.dot(eye), f.dot(eye), 1.0);
    return result;
  }

  Matrix4 _perspective(double fovy, double aspect, double zNear, double zFar) {
    double tanHalfFovy = tan(fovy / 2.0);

    Matrix4 result = Matrix4.zero();
    result.row0 = Vector4(1.0 / (aspect * tanHalfFovy), 0, 0, 0);
    result.row1 = Vector4(0.0, 1.0 / tanHalfFovy, 0, 0);
    result.row2 = Vector4(0.0, 0, -(zFar + zNear) / (zFar - zNear), -1.0);
    result.row3 = Vector4(0.0, 0, -(2.0 * zFar * zNear) / (zFar - zNear), 0.0);
    return result;
  }
}
