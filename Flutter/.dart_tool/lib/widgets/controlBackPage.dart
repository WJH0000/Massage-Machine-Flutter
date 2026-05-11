import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:easy_localization/easy_localization.dart';

class ControlBackPage extends StatelessWidget {
  final double activePaddingValue;
  final int currentStep;
  final List<dynamic> processStep;
  final String currentProcessTimeLeft;
  final bool isPause;

  ControlBackPage({required this.activePaddingValue, required this.currentStep, required this.processStep, required this.currentProcessTimeLeft, required this.isPause});

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Container(
        width: MediaQuery.of(context).size.width - 18,
        // padding: EdgeInsets.all(10),
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
        margin: EdgeInsets.only(top: 20, bottom: 20),
        child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color(0xF6698FFa),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
                  ),
                  child: Text(
                    currentProcessTimeLeft,
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "currentProcess",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ).tr(),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    StepProgressIndicator(
                        roundedEdges: Radius.circular(10),
                        totalSteps: processStep.length,
                        currentStep: currentStep + 1,
                        size: 60,
                        selectedColor: Color(0xFFF0F3FE),
                        unselectedColor: Color(0xF6d7d7d7),
                        customStep: (index, color, _) => AnimatedPadding(
                              padding: index == currentStep ? EdgeInsets.all(activePaddingValue) : EdgeInsets.all(5),
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.easeInOut,
                              child: Container(
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text(
                                      'mins'.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ).tr(namedArgs: {'value': processStep[index]["displayText"]}),
                                    Flexible(
                                        child: index == currentStep
                                            ? isPause
                                                ? Text("paused",
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    )).tr()
                                                : Image.asset(
                                                    'assets/img/progress.gif',
                                                    fit: BoxFit.fitWidth,
                                                    width: 500,
                                                    height: 30,
                                                  )
                                            : index < currentStep
                                                ? Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green[400],
                                                  )
                                                : Icon(
                                                    Icons.remove,
                                                    color: Colors.grey,
                                                  ))
                                  ]),
                                  decoration: BoxDecoration(
                                    color: color,
                                    border: index == currentStep ? Border.all(color: Colors.red, width: 3) : Border.all(color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  )),
                            )
                        // color == Color(0xFFF0F3FE) &&
                        //         index == (currentStep - 1)
                        //     ? AnimatedPadding(
                        //         padding: EdgeInsets.all(activePaddingValue),
                        //         duration: Duration(milliseconds: 1000),
                        //         curve: Curves.easeInOut,
                        //         child: Container(
                        //             child: Flexible(
                        //               flex: 1,
                        //               child: Column(
                        //                   mainAxisAlignment: MainAxisAlignment.center,
                        //                   children: [
                        //                     Text(
                        //                       processStep[currentStep - 1]
                        //                               ["displayText"]
                        //                           .toString(),
                        //                       textAlign: TextAlign.center,
                        //                       style: TextStyle(
                        //                         fontWeight: FontWeight.bold,
                        //                       ),
                        //                     ),
                        //                     Flexible(
                        //                         child: Image.asset(
                        //                       'assets/img/progress.gif',
                        //                       fit: BoxFit.fitWidth,
                        //                       width: 500,
                        //                       height: 30,
                        //                     ))
                        //                   ]),
                        //             ),
                        //             decoration: BoxDecoration(
                        //               color: color,
                        //               border: Border.all(color: Colors.red, width: 3),
                        //               borderRadius:
                        //                   BorderRadius.all(Radius.circular(5)),
                        //             )),
                        //       )
                        //     : index < currentStep
                        //         ? Padding(
                        //             padding: EdgeInsets.all(6),
                        //             child: Container(
                        //               child: Column(
                        //                   mainAxisAlignment: MainAxisAlignment.center,
                        //                   children: [
                        //                     Text(
                        //                       "First 10 mins ",
                        //                       textAlign: TextAlign.center,
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.bold),
                        //                     ),
                        //                     Flexible(
                        //                         child: Icon(
                        //                       Icons.check_circle,
                        //                       color: Colors.green[400],
                        //                     ))
                        //                   ]),
                        //               decoration: BoxDecoration(
                        //                 color: color,
                        //                 border:
                        //                     Border.all(color: Colors.grey, width: 1),
                        //                 borderRadius:
                        //                     BorderRadius.all(Radius.circular(5)),
                        //               ),
                        //             ),
                        //           )
                        //         : Padding(
                        //             padding: EdgeInsets.all(6),
                        //             child: Container(
                        //               child: Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 children: [
                        //                   Text(
                        //                     "Last 10 mins ",
                        //                     textAlign: TextAlign.center,
                        //                     style: TextStyle(
                        //                       fontWeight: FontWeight.bold,
                        //                       color: Color(0xF6d7d7d7a),
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //               decoration: BoxDecoration(
                        //                 color: color,
                        //                 border:
                        //                     Border.all(color: Colors.grey, width: 1),
                        //                 borderRadius:
                        //                     BorderRadius.all(Radius.circular(5)),
                        //               ),
                        //             )),
                        ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "strengthLevel",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ).tr(),
                      Flexible(
                        child: Text(
                          processStep.length != 0 ? processStep[currentStep]["strength"].toString() : "",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  child: processStep.length == (currentStep + 1)
                      ? null
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "nextExecutionStrengthLevel",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ).tr(),
                            Text(
                              processStep[currentStep + 1]["strength"].toString(),
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ],
            )));
  }
}
