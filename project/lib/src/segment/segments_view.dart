import 'package:ai_driven_cars/src/utils/utils.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'segment.dart';


class SegmentsView extends StatelessWidget {
  final List<Segment> segments;
  final double drawingTopOffset;
  const SegmentsView(this.segments, {super.key, this.drawingTopOffset = 0,});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: screenSize!,
      painter: SegmentsPainter(segments, drawingTopOffset),
    );
  }
}


class SegmentsPainter extends CustomPainter {
  final List<Segment> segments;
  final double drawingTopOffset;
  const SegmentsPainter(this.segments, this.drawingTopOffset);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = sw;
    for (var segment in segments) {
      if(segment.isDotted && (segment.start.dx == segment.end.dx)){
        double dashHeight = 2*sh, 
          dashSpace = 3*sh,
          distance = (segment.start.dy - segment.end.dy).abs(),
          startY = drawingTopOffset.remainder(dashHeight + dashSpace);
        while (startY < distance) {
          canvas.drawLine(Offset(segment.start.dx, startY), Offset(segment.start.dx, startY + dashHeight), paint);
          startY += dashHeight + dashSpace;
        }
      } 
      else if (segment.percentageColored != null) {
        double percentage = segment.percentageColored!;
        paint.color = Colors.yellow;
        Offset drawStart = Offset(segment.start.dx, segment.start.dy + drawingTopOffset);
        Offset drawEnd = Offset(segment.end.dx, segment.end.dy + drawingTopOffset);
        Offset drawMid = getMiddle(drawStart, drawEnd, percentage);
        canvas.drawLine(drawStart, drawMid, paint);
        paint.color = Colors.black;
        canvas.drawLine(drawMid, drawEnd, paint);
      } 
      else {
        Offset drawStart = Offset(segment.start.dx, segment.start.dy + drawingTopOffset);
        Offset drawEnd = Offset(segment.end.dx, segment.end.dy + drawingTopOffset);
        canvas.drawLine(drawStart, drawEnd, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant SegmentsPainter oldDelegate) {
    return segments != oldDelegate.segments;
  }
  
  Offset getMiddle(Offset drawStart, Offset drawEnd, double ratio) {
    return Offset(
      lerp(drawStart.dx, drawEnd.dx, ratio).toDouble(),
      lerp(drawStart.dy, drawEnd.dy, ratio).toDouble()
    );
  }
}