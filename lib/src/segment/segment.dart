import 'dart:math';
import 'dart:ui';

import '../utils/utils.dart';
import '../touch/touch.dart';

class Segment {
  final Offset start;
  final Offset end;
  bool isDotted;

  Segment(this.start, this.end, {isDotted}) : isDotted = isDotted ?? false;

  Touch? getIntersection(Segment obstacle){
    Offset a = start;
    Offset b = end;
    Offset c = obstacle.start;
    Offset d = obstacle.end;

    var tTop = (d.dx - c.dx)*(a.dy - c.dy) - (d.dy - c.dy)*(a.dx - c.dx); 
    var uTop = (c.dy - a.dy)*(a.dx - b.dx) - (c.dx - a.dx)*(a.dy - b.dy);
    var bottom = (d.dy - c.dy)*(b.dx - a.dx) - (d.dx - c.dx)*(b.dy - a.dy);

    if(bottom != 0){
      var t = tTop/bottom;
      var u = uTop/bottom;
      if(t>=0 && t<=1 && u>=0 && u<=1){
        return Touch(
          Point(
            lerp(a.dx, b.dx, t),
            lerp(a.dy, b.dy, t),
          ),
          t
        );
      }
    }
    return null;
  }
}