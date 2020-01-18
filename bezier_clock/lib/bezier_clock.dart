import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BezierClock extends StatefulWidget {
  const BezierClock(this.model);

  final ClockModel model;

  @override
  _BezierClockState createState() => _BezierClockState();
}

class _BezierClockState extends State<BezierClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(BezierClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  int get12Hour(int hour) {
    var mod = hour % 12;
    return mod == 0 ? 12 : mod;
  }

  @override
  Widget build(BuildContext context) {
    var style =
    Theme.of(context).textTheme.body1.copyWith(fontFamily: 'Chilanka');
    bool is24 = widget.model.is24HourFormat;
    var hour = is24 ? _dateTime.hour : get12Hour(_dateTime.hour);
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Row(
            children: <Widget>[
              Spacer(),
              Expanded(child: BezierDigit(digit: hour ~/ 10)),
              Expanded(child: BezierDigit(digit: hour % 10)),
              Text(':', style: style.copyWith(fontSize: 64)),
              Expanded(child: BezierDigit(digit: _dateTime.minute ~/ 10)),
              Expanded(child: BezierDigit(digit: _dateTime.minute % 10)),
              Text(':', style: style.copyWith(fontSize: 64)),
              Expanded(child: BezierDigit(digit: _dateTime.second ~/ 10)),
              Expanded(child: BezierDigit(digit: _dateTime.second % 10)),
              if (!is24)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _dateTime.hour < 12 ? 'AM' : 'PM',
                    style: style.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Spacer(),
            ],
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${widget.model.temperatureString}',
                  style: style.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.model.weatherString}',
                  style: style.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BezierDigit extends StatefulWidget {
  final int digit;

  const BezierDigit({Key key, this.digit}) : super(key: key);

  @override
  _BezierDigitState createState() => _BezierDigitState();
}

class _BezierDigitState extends State<BezierDigit>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      value: 1.0,
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(BezierDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit == widget.digit) return;
    controller.reset();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => CustomPaint(
          painter: ShapesPainter(
            Points.betweenPoint(widget.digit, controller.value),
            isDark ? Colors.white : Colors.black,
          ),
          child: AspectRatio(aspectRatio: 0.7),
        ),
      ),
    );
  }
}

class ShapesPainter extends CustomPainter {
  final point;
  final Color color;

  ShapesPainter(this.point, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    // create a path
    var w = size.width;
    var h = size.height;

    var path = Path();
    var p1 = point[0];
    path.moveTo(p1[0][0] * w, p1[0][1] * h);
    var p2 = point[1];
    path.cubicTo(p1[1][0] * w, p1[1][1] * h, p2[0][0] * w, p2[0][1] * h,
        p2[1][0] * w, p2[1][1] * h);
    var p3 = point[2];
    path.cubicTo(p2[2][0] * w, p2[2][1] * h, p3[0][0] * w, p3[0][1] * h,
        p3[1][0] * w, p3[1][1] * h);
    var p4 = point[3];
    path.cubicTo(p3[2][0] * w, p3[2][1] * h, p4[0][0] * w, p4[0][1] * h,
        p4[1][0] * w, p4[1][1] * h);
    var p5 = point[4];
    path.cubicTo(p4[2][0] * w, p4[2][1] * h, p5[0][0] * w, p5[0][1] * h,
        p5[1][0] * w, p5[1][1] * h);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ShapesPainter oldDelegate) => oldDelegate != this;
}

class Points {
  static const array = [
    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine
  ];

  static const zero = [
    [
      [0.5, 0.04],
      [0.1, 0.1]
    ],
    [
      [0.04, 0.3],
      [0.02, 0.5],
      [0.00, 0.7],
    ],
    [
      [0.1, 0.98],
      [0.5, 0.98],
      [0.9, 0.98],
    ],
    [
      [1.0, 0.65],
      [0.98, 0.5],
      [0.96, 0.3],
    ],
    [
      [0.9, 0.09],
      [0.4, 0.10],
    ],
  ];

  static const one = [
    [
      [0.4, 0.2],
      [0.5, 0.1]
    ],
    [
      [0.55, 0.09],
      [0.6, 0.05],
      [0.65, 0.0],
    ],
    [
      [0.6, 0.2],
      [0.6, 0.4],
      [0.6, 0.65],
    ],
    [
      [0.6, 0.45],
      [0.6, 0.6],
      [0.6, 0.75],
    ],
    [
      [0.6, 0.65],
      [0.6, 0.95],
    ],
  ];

  static const two = [
    [
      [0.05, 0.2],
      [0.1, 0.1]
    ],
    [
      [0.35, 0.02],
      [0.65, 0.1],
      [0.9, 0.2],
    ],
    [
      [0.86, 0.4],
      [0.82, 0.5],
      [0.7, 0.7],
    ],
    [
      [0.1, 1.0],
      [0.05, 0.85],
      [0.04, 0.7],
    ],
    [
      [0.8, 0.88],
      [0.9, 0.9],
    ],
  ];

  static const three = [
    [
      [0.02, 0.25],
      [0.04, 0.0]
    ],
    [
      [0.73, 0.05],
      [0.78, 0.22],
      [0.85, 0.5],
    ],
    [
      [0.3, 0.6],
      [0.3, 0.5],
      [0.3, 0.4],
    ],
    [
      [0.9, 0.6],
      [0.8, 0.8],
      [0.7, 0.95],
    ],
    [
      [0.04, 1.0],
      [0.02, 0.9],
    ],
  ];

  static const four = [
    [
      [0.95, 0.6],
      [0.5, 0.6]
    ],
    [
      [0.3, 0.6],
      [0.1, 0.6],
      [0.0, 0.59],
    ],
    [
      [0.2, 0.4],
      [0.45, 0.2],
      [0.55, 0.1],
    ],
    [
      [0.7, 0.0],
      [0.7, 0.1],
      [0.7, 0.5],
    ],
    [
      [0.7, 0.85],
      [0.7, 0.95],
    ],
  ];

  static const five = [
    [
      [0.95, 0.06],
      [0.5, 0.01]
    ],
    [
      [0.06, 0.0],
      [0.04, 0.05],
      [0.02, 0.06],
    ],
    [
      [0.02, 0.38],
      [0.04, 0.4],
      [0.06, 0.42],
    ],
    [
      [0.98, 0.3],
      [0.98, 0.6],
      [0.98, 0.9],
    ],
    [
      [0.5, 0.95],
      [0.02, 0.9],
    ],
  ];

  static const six = [
    [
      [0.68, 0.02],
      [0.3, 0.1]
    ],
    [
      [0.02, 0.4],
      [0.02, 0.6],
      [0.02, 0.8],
    ],
    [
      [0.2, 0.95],
      [0.5, 0.95],
      [0.7, 0.95],
    ],
    [
      [0.91, 0.9],
      [0.89, 0.7],
      [0.88, 0.5],
    ],
    [
      [0.3, 0.3],
      [0.02, 0.6],
    ],
  ];

  static const seven = [
    [
      [0.02, 0.04],
      [0.1, 0.02],
    ],
    [
      [0.88, 0.02],
      [0.88, 0.02],
      [0.88, 0.02],
    ],
    [
      [0.88, 0.05],
      [0.75, 0.24],
      [0.7, 0.32],
    ],
    [
      [0.63, 0.55],
      [0.6, 0.6],
      [0.57, 0.65],
    ],
    [
      [0.4, 0.93],
      [0.4, 0.95],
    ],
  ];

  static const eight = [
    [
      [0.5, 0.48],
      [0.9, 0.4],
    ],
    [
      [0.8, 0.05],
      [0.5, 0.05],
      [0.2, 0.05],
    ],
    [
      [0.0, 0.4],
      [0.5, 0.5],
      [1.0, 0.6],
    ],
    [
      [1.0, 0.95],
      [0.5, 0.95],
      [0, 0.95],
    ],
    [
      [0.0, 0.6],
      [0.5, 0.48],
    ],
  ];

  static const nine = [
    [
      [0.88, 0.2],
      [0.9, 0.0],
    ],
    [
      [0.05, 0.00],
      [0.05, 0.2],
      [0.05, 0.3],
    ],
    [
      [0.2, 0.4],
      [0.5, 0.4],
      [0.7, 0.4],
    ],
    [
      [0.95, 0.3],
      [0.9, 0.22],
      [0.85, 0.17],
    ],
    [
      [0.9, 0.8],
      [0.9, 0.98],
    ],
  ];

  static betweenPoint(count, double offset) {
    var first = array[(count - 1) % 10];
    var second = array[count];
    double cal(int x1, int x2, int x3) {
      return (1 - offset) * first[x1][x2][x3] + offset * second[x1][x2][x3];
    }

    return [
      [
        [cal(0, 0, 0), cal(0, 0, 1)],
        [cal(0, 1, 0), cal(0, 1, 1)]
      ],
      [
        [cal(1, 0, 0), cal(1, 0, 1)],
        [cal(1, 1, 0), cal(1, 1, 1)],
        [cal(1, 2, 0), cal(1, 2, 1)],
      ],
      [
        [cal(2, 0, 0), cal(2, 0, 1)],
        [cal(2, 1, 0), cal(2, 1, 1)],
        [cal(2, 2, 0), cal(2, 2, 1)],
      ],
      [
        [cal(3, 0, 0), cal(3, 0, 1)],
        [cal(3, 1, 0), cal(3, 1, 1)],
        [cal(3, 2, 0), cal(3, 2, 1)],
      ],
      [
        [cal(4, 0, 0), cal(4, 0, 1)],
        [cal(4, 1, 0), cal(4, 1, 1)],
      ],
    ];
  }
}