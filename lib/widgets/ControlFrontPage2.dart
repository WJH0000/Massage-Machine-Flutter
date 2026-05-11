import 'dart:math';
import 'package:control_app/view/test.dart';
import 'package:control_app/widgets/SlideNumberPicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:timelines/timelines.dart';
import 'package:control_app/const/constant.dart';
import 'package:easy_localization/easy_localization.dart';

class ControlFrontPage2 extends StatelessWidget {
  final List<dynamic> processList;
  final int usedTime;
  final Function startMassageProcess;
  final Function deleteConfirmationDialog;
  final Function initializeBottomSheetValueForOrAndEdit;
  final Function performAddUpdateDeleteMassageSetting;

  ControlFrontPage2({
    required this.processList,
    required this.usedTime,
    required this.startMassageProcess,
    required this.deleteConfirmationDialog,
    required this.initializeBottomSheetValueForOrAndEdit,
    required this.performAddUpdateDeleteMassageSetting,
  });

  static const completeColor = Color(0xff5e6172);
  static const inProgressColor = Color(0xF6698FFa);
  static const todoColor = Color(0xffd1d2d7);

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
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "duration",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ).tr(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        usedTime.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'mins',
                        style: TextStyle(color: Colors.grey),
                      ).tr(),
                      Text(
                        'timeUsed'.toString(),
                        style: TextStyle(color: Colors.grey),
                      ).tr(),
                      Text(
                        (30 - usedTime).toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'mins',
                        style: TextStyle(color: Colors.grey),
                      ).tr(),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 9,
              ),
              Container(
                height: 10,
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Row(
                      children: List.generate(
                        processList.length,
                        (index) {
                          var border;
                          if (processList.length == 1) {
                            border = BorderRadius.only(
                              bottomLeft: Radius.circular(5.0),
                              topLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0),
                              topRight: Radius.circular(5.0),
                            );
                          } else {
                            if (index == 0)
                              border = BorderRadius.only(
                                bottomLeft: Radius.circular(5.0),
                                topLeft: Radius.circular(5.0),
                              );
                            else if (index == (processList.length - 1))
                              border = BorderRadius.only(
                                bottomRight: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                              );
                            else
                              border = BorderRadius.zero;
                          }
                          //Determine the border radius

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: border,
                              color: processList[index]['color'],
                            ),
                            width: constraints.maxWidth * (processList[index]['duration'] / 30),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.post_add,
                      size: 30,
                      color: Colors.black,
                    ),
                    tooltip: 'addMassageStrength'.tr(),
                    onPressed: usedTime == 30
                        ? null
                        : () {
                            initializeBottomSheetValueForOrAndEdit(0, false);
                          },
                  ),
                ],
              ),
              SizedBox(
                height: 250,
                child: Container(
                  decoration: BoxDecoration(
                    //color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: processList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (processList[index]['strengthLevel'] == 0) {
                        return SizedBox();
                      } else {
                        return Slidable(
                            // Specify a key if the Slidable is dismissible.
                            key: const ValueKey(0),

                            // The end action pane is the one at the right or the bottom side.
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),

                              // A pane can dismiss the Slidable.
                              // dismissible: DismissiblePane(onDismissed: () {
                              //   print("gone************");
                              // }),

                              children: [
                                SlidableAction(
                                  // An action can be bigger than the others.

                                  onPressed: (BuildContext context) {
                                    initializeBottomSheetValueForOrAndEdit(index, true);
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                                SlidableAction(
                                  onPressed: (BuildContext context) {
                                    deleteConfirmationDialog(index);
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            // The child of the Slidable is what the user sees when the
                            // component is not dragged.
                            child: Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: ListTile(
                                onTap: () {
                                  initializeBottomSheetValueForOrAndEdit(index, true);
                                },
                                leading: Container(
                                  alignment: Alignment.center,
                                  height: 70,
                                  width: 110,
                                  padding: EdgeInsets.all(11.0),
                                  decoration: BoxDecoration(
                                    color: processList[index]['color'],
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Text(
                                    'minutesWithValue'.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).tr(namedArgs: {'value': processList[index]['duration'].toString()}),
                                ),
                                title: Row(children: [
                                  Text(
                                    "strengthLevel",
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ).tr(),
                                  Text(
                                    processList[index]['strengthLevel'].toString(),
                                    style: Theme.of(context).textTheme.subtitle2,
                                  )
                                ]),
                                // subtitle: Row(children: [
                                //   Text(
                                //     "strengthLevel",
                                //     style: Theme.of(context).textTheme.subtitle1,
                                //   ).tr(),
                                //   Text(
                                //     "50",
                                //     style: Theme.of(context).textTheme.subtitle2,
                                //   )
                                // ]),
                                // trailing: IconButton(
                                //   icon: Icon(Icons.more_vert),
                                //   onPressed: () {},
                                // ),
                              ),
                            ));
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      child: Text(
                        "start",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ).tr(),
                      onPressed: () {
                        startMassageProcess();
                      },
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
