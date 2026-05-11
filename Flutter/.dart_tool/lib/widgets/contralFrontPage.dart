import 'dart:math';
import 'package:control_app/widgets/SlideNumberPicker.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';
import 'package:control_app/const/constant.dart';
import 'package:easy_localization/easy_localization.dart';

class ControlFrontPage extends StatelessWidget {
  final int processIndex;
  final List<int> timeDurationList;
  final Function updateStrengthValue;
  final Function stepIndicatorOnChange;

  ControlFrontPage({required this.processIndex, required this.timeDurationList, required this.updateStrengthValue, required this.stepIndicatorOnChange});

  static const completeColor = Color(0xff5e6172);
  static const inProgressColor = Color(0xF6698FFa);
  static const todoColor = Color(0xffd1d2d7);

  Color getColor(int index) {
    if (index == (processIndex + 1)) {
      return inProgressColor;
    } else if (index < (processIndex + 1)) {
      return completeColor;
    } else {
      return todoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Container(
      width: MediaQuery.of(context).size.width - 10,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 120,
                child: Timeline.tileBuilder(
                  theme: TimelineThemeData(
                    direction: Axis.horizontal,
                    connectorTheme: ConnectorThemeData(
                      space: 30.0,
                      thickness: 5.0,
                    ),
                  ),
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.before,
                    itemExtentBuilder: (_, __) => MediaQuery.of(context).size.width / displayTime.length - 2,
                    oppositeContentsBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                        child: Text(
                          'minutesWithValue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getColor(index),
                          ),
                        ).tr(namedArgs: {'value': displayTime[index]}),
                      );
                    },
                    // contentsBuilder: (context, index) {
                    //   return Padding(
                    //     padding:
                    //         const EdgeInsets.only(top: 15.0),
                    //     child: Text(
                    //       _processes[index],
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: getColor(index),
                    //       ),
                    //     ),
                    //   );
                    // },
                    indicatorBuilder: (_, index) {
                      var color;
                      var child;
                      if (index == (processIndex + 1)) {
                        color = inProgressColor;
                        child = Icon(
                          Icons.airport_shuttle,
                          color: Colors.white,
                          size: 15.0,
                        );
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: CircularProgressIndicator(
                        //     strokeWidth: 3.0,
                        //     valueColor: AlwaysStoppedAnimation(Colors.white),
                        //   ),
                        // );
                      } else if (index < (processIndex + 1)) {
                        color = completeColor;
                        child = Icon(
                          Icons.alarm_on_sharp,
                          color: Colors.white,
                          size: 15.0,
                        );
                      } else {
                        color = todoColor;
                      }

                      if (index <= (processIndex + 1)) {
                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size(30.0, 30.0),
                              painter: _BezierPainter(
                                color: color,
                                drawStart: index > 0,
                                drawEnd: index < (processIndex + 1),
                              ),
                            ),
                            DotIndicator(
                              size: 30.0,
                              color: color,
                              child: child,
                            ),
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size(15.0, 15.0),
                              painter: _BezierPainter(
                                color: color,
                                drawEnd: index < displayTime.length - 1,
                              ),
                            ),
                            OutlinedDotIndicator(
                              borderWidth: 4.0,
                              color: color,
                            ),
                          ],
                        );
                      }
                    },
                    connectorBuilder: (_, index, type) {
                      if (index > 0) {
                        if (index == (processIndex + 1)) {
                          final prevColor = getColor(index - 1);
                          final color = getColor(index);
                          List<Color> gradientColors;
                          if (type == ConnectorType.start) {
                            gradientColors = [Color.lerp(prevColor, color, 0.5)!, color];
                          } else {
                            gradientColors = [prevColor, Color.lerp(prevColor, color, 0.5)!];
                          }
                          return DecoratedLineConnector(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                              ),
                            ),
                          );
                        } else {
                          return SolidLineConnector(
                            color: getColor(index),
                          );
                        }
                      } else {
                        return null;
                      }
                    },
                    itemCount: displayTime.length,
                  ),
                ),
              ),
              // FlutterToggleTab(
              //   // width in percent
              //   width: 95,
              //   borderRadius: 10,
              //   height: 50,
              //   selectedIndex: _tabTextIndexSelected,
              //   selectedBackgroundColors: [
              //     Color(0xF6698FFa),
              //     Colors.blueAccent
              //   ],
              //   selectedTextStyle: TextStyle(
              //       color: Colors.white,
              //       fontSize: 15,
              //       fontWeight: FontWeight.w700),
              //   unSelectedTextStyle: TextStyle(
              //       color: Colors.black87,
              //       fontSize: 14,
              //       fontWeight: FontWeight.w500),
              //   labels: _listTextTabToggle,
              //   selectedLabelIndex: (index) {
              //     setState(() {
              //       _tabTextIndexSelected = index;
              //       _currentHorizontalIntValue =
              //           timeDurationList[index];
              //     });
              //     print("index " + index.toString());
              //   },
              //   isScroll: false,
              // ),

              Text("strength", style: Theme.of(context).textTheme.headline6).tr(),
              SizedBox(
                height: 10,
              ),
              Container(
                  // decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  //     boxShadow: [
                  //       BoxShadow(
                  //           color: Colors.black12,
                  //           spreadRadius: 2.0,
                  //           blurRadius: 5.0),
                  //     ]),
                  child: Stack(children: [
                processIndex == 0 ? SlideNumberPicker(currentValue: timeDurationList[processIndex], onChangeValue: updateStrengthValue) : Text(""),
                processIndex == 1 ? SlideNumberPicker(currentValue: timeDurationList[processIndex], onChangeValue: updateStrengthValue) : Text(""),
                processIndex == 2 ? SlideNumberPicker(currentValue: timeDurationList[processIndex], onChangeValue: updateStrengthValue) : Text(""),
                // NumberPicker(
                //   value: _currentHorizontalIntValue,
                //   textStyle: TextStyle(color: Colors.grey, fontSize: 12),
                //   selectedTextStyle: TextStyle(
                //       color: Colors.black,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 25),
                //   minValue: 0,
                //   maxValue: 100,
                //   step: 1,
                //   itemHeight: 70,
                //   axis: Axis.horizontal,
                //   onChanged: (value) => setState(() => {
                //         _currentHorizontalIntValue = value,
                //         timeDurationList[_tabTextIndexSelected] = value
                //       }),
                //   decoration: BoxDecoration(
                //       //color: Colors.white,

                //       borderRadius: BorderRadius.all(Radius.circular(20.0)),
                //       boxShadow: [
                //         BoxShadow(
                //             color: Colors.black12,
                //             spreadRadius: 2.0,
                //             blurRadius: 5.0),
                //       ]),
                // ),
                Positioned(
                  left: 135,
                  top: 55,
                  child: Icon(
                    Icons.arrow_drop_up,
                    color: Color(0xF6698FFa),
                  ),
                ),
              ])),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      child: Text(
                        "back",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ).tr(),
                      onPressed: processIndex == 0 ? null : () => stepIndicatorOnChange(true),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xF6698FFa),
                        onPrimary: Colors.white,
                        padding: EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      child: Text(
                        "next",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ).tr(),
                      onPressed: processIndex == 2 || timeDurationList[processIndex] == 0 ? null : () => stepIndicatorOnChange(false),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xF6698FFa),
                        onPrimary: Colors.white,
                        padding: EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius, radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius, radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.drawStart != drawStart || oldDelegate.drawEnd != drawEnd;
  }
}
