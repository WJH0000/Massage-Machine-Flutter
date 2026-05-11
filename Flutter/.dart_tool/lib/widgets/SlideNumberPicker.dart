import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class SlideNumberPicker extends StatelessWidget {
  final int currentValue;
  final Function onChangeValue;

  SlideNumberPicker({required this.currentValue, required this.onChangeValue});

  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      value: currentValue,
      textStyle: TextStyle(color: Colors.grey, fontSize: 12),
      selectedTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
      minValue: 0,
      maxValue: 100,
      step: 10,
      itemHeight: 70,
      axis: Axis.horizontal,
      onChanged: (value) => {onChangeValue(value)},
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), boxShadow: [
        BoxShadow(color: Colors.black12, spreadRadius: 2.0, blurRadius: 5.0),
      ]),
    );
  }
}
