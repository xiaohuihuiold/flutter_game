import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class GameObject {
  double get z;
}

class GameFace extends GameObject {
  List<Vector3> vertices;
  ui.Color color;

  @override
  double get z {
    double z = 0;
    vertices?.forEach((vertex) {
      z += vertex.z;
    });
    return z;
  }
}

abstract class GameObjectGroup {
  List<GameFace> faces;
  List<Color> colors;

  List<GameFace> transform(Float64List float64list);
}

class Cube extends GameObjectGroup {
  static img.Image dirt;

  Cube() {
    if (dirt != null) return;
    GameUtil._loadImage('assets/dirt.png').then((image) {
      dirt = image;
    });
  }

  @override
  List<GameFace> get faces => _generaCube();

  List<GameFace> _generaCube() {
    List<GameFace> gameFaces = List();
    for (int w = 0; w < 16; w++) {
      for (int h = 0; h < 16; h++) {
        double size = 1.0 / 16.0;

        double left = w / 16 - 0.5;
        double bottom = h / 16 - 0.5;
        double right = left + size;
        double top = bottom + size;

        GameFace backFace = GameFace();
        backFace.color = GameUtil.abgr2argb(dirt?.getPixel(w, h));
        backFace.vertices = [
          Vector3(left, bottom, -0.5),
          Vector3(right, bottom, -0.5),
          Vector3(right, top, -0.5),
          Vector3(left, top, -0.5),
        ];
        gameFaces.add(backFace);

        GameFace frontFace = GameFace();
        frontFace.color = GameUtil.abgr2argb(dirt?.getPixel(w, h));
        frontFace.vertices = [
          Vector3(left, bottom, 0.5),
          Vector3(right, bottom, 0.5),
          Vector3(right, top, 0.5),
          Vector3(left, top, 0.5),
        ];
        gameFaces.add(frontFace);

        GameFace bottomFace = GameFace();
        bottomFace.color = GameUtil.abgr2argb(dirt?.getPixel(w, h));
        bottomFace.vertices = [
          Vector3(left, -0.5, bottom),
          Vector3(right, -0.5, bottom),
          Vector3(right, -0.5, top),
          Vector3(left, -0.5, top),
        ];
        gameFaces.add(bottomFace);

        GameFace topFace = GameFace();
        topFace.color = GameUtil.abgr2argb(dirt?.getPixel(w, h));
        topFace.vertices = [
          Vector3(left, 0.5, bottom),
          Vector3(right, 0.5, bottom),
          Vector3(right, 0.5, top),
          Vector3(left, 0.5, top),
        ];
        gameFaces.add(topFace);

        GameFace leftFace = GameFace();
        leftFace.color = GameUtil.abgr2argb(dirt?.getPixel(w, h));
        leftFace.vertices = [
          Vector3(-0.5, left, bottom),
          Vector3(-0.5, right, bottom),
          Vector3(-0.5, right, top),
          Vector3(-0.5, left, top),
        ];
        gameFaces.add(leftFace);

        GameFace rightFace = GameFace();
        rightFace.color = GameUtil.abgr2argb(dirt?.getPixel(w, h));
        rightFace.vertices = [
          Vector3(0.5, left, bottom),
          Vector3(0.5, right, bottom),
          Vector3(0.5, right, top),
          Vector3(0.5, left, top),
        ];
        gameFaces.add(rightFace);
      }
    }
    return gameFaces;
  }

  @override
  List<GameFace> transform(Float64List float64list) {
    Matrix4 matrix4 = Matrix4.fromFloat64List(float64list);
    List<GameFace> faces = this.faces;
    faces.forEach((face) {
      for (int i = 0; i < face.vertices.length; i++) {
        matrix4.perspectiveTransform(face.vertices[i]);
      }
    });
    return faces;
  }
}

class GameUtil {
  static List<GameFace> getAllObject(List<GameObjectGroup> groups) {
    if (groups == null) {
      return null;
    }
    List<GameFace> faces = List();
    groups.forEach((group) {
      faces.addAll(group.faces);
    });
    return faces;
  }

  static List<GameFace> orderZ(List<GameFace> gameFaces) {
    List<GameObject> faces = List<GameFace>.from(gameFaces);
    faces.sort((a, b) => a.z.compareTo(b.z));
    return faces;
  }

  static Path generaFace(GameFace face, Size size) {
    if ((face?.vertices?.length ?? 0) < 1 || size == null) {
      return null;
    }
    Path path = Path();
    double w = size.width / 2.0;
    double h = size.height / 2.0;
    path.moveTo(face.vertices[0].x * w + w, -(face.vertices[0].y * h) + h);
    for (int i = 1; i < face.vertices.length; i++) {
      path.lineTo(face.vertices[i].x * w + w, -(face.vertices[i].y * h) + h);
    }
    path.close();
    return path;
  }

  static Color abgr2argb(int color) {
    if (color == null) {
      return null;
    }
    return Color.fromARGB(
        color >> 24, color & 0xff, (color >> 8) & 0xff, color >> (16 & 0xff));
  }

  static Map<String, img.Image> _imageCache = Map();

  static Future<img.Image> _loadImage(String path) async {
    img.Image image = _imageCache[path.trim()];
    if (image != null) {
      return image;
    }
    image = img.decodeImage((await rootBundle.load(path)).buffer.asUint8List());
    _imageCache[path.trim()] = image;
    return image;
  }
}
