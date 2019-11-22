import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
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
  @override
  List<GameFace> get faces => _generaCube();

  List<GameFace> _generaCube() {
    List<GameFace> gameFaces = List();
    GameFace back = GameFace()
      ..color = ui.Color.fromARGB(255, 255, 0, 0)
      ..vertices = [
        Vector3(-1.0, -1.0, -1.0),
        Vector3(1.0, -1.0, -1.0),
        Vector3(1.0, 1.0, -1.0),
        Vector3(-1.0, 1.0, -1.0),
      ];
    GameFace front = GameFace()
      ..color = ui.Color.fromARGB(255, 0, 255, 0)
      ..vertices = [
        Vector3(-1.0, -1.0, 1.0),
        Vector3(1.0, -1.0, 1.0),
        Vector3(1.0, 1.0, 1.0),
        Vector3(-1.0, 1.0, 1.0),
      ];
    GameFace top = GameFace()
      ..color = ui.Color.fromARGB(255, 0, 0, 255)
      ..vertices = [
        Vector3(-1.0, 1.0, 1.0),
        Vector3(1.0, 1.0, 1.0),
        Vector3(1.0, 1.0, -1.0),
        Vector3(-1.0, 1.0, -1.0),
      ];
    GameFace bottom = GameFace()
      ..color = ui.Color.fromARGB(255, 255, 255, 0)
      ..vertices = [
        Vector3(-1.0, -1.0, 1.0),
        Vector3(1.0, -1.0, 1.0),
        Vector3(1.0, -1.0, -1.0),
        Vector3(-1.0, -1.0, -1.0),
      ];
    GameFace left = GameFace()
      ..color = ui.Color.fromARGB(255, 255, 0, 255)
      ..vertices = [
        Vector3(-1.0, -1.0, 1.0),
        Vector3(-1.0, -1.0, -1.0),
        Vector3(-1.0, 1.0, -1.0),
        Vector3(-1.0, 1.0, 1.0),
      ];
    GameFace right = GameFace()
      ..color = ui.Color.fromARGB(255, 0, 255, 255)
      ..vertices = [
        Vector3(1.0, -1.0, 1.0),
        Vector3(1.0, -1.0, -1.0),
        Vector3(1.0, 1.0, -1.0),
        Vector3(1.0, 1.0, 1.0),
      ];
    gameFaces.add(front);
    gameFaces.add(back);
    gameFaces.add(top);
    gameFaces.add(bottom);
    gameFaces.add(left);
    gameFaces.add(right);
    return gameFaces;
  }

  @override
  List<GameFace> transform(Float64List float64list) {
    Matrix4 matrix4 = Matrix4.fromFloat64List(float64list);
    List<GameFace> faces = this.faces;
    faces.forEach((face) {
      face.vertices?.forEach((vertex) {
        matrix4.perspectiveTransform(vertex);
      });
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

  static Path generaFace(GameFace face) {
    if ((face?.vertices?.length ?? 0) < 1) {
      return null;
    }
    Path path = Path();
    path.moveTo(face.vertices[0].x, face.vertices[0].y);
    for (int i = 1; i < face.vertices.length; i++) {
      path.lineTo(face.vertices[i].x, face.vertices[i].y);
    }
    path.close();
    return path;
  }
}
