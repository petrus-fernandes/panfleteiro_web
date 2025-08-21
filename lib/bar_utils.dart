import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class BarUtils {
  static void showTopFlushBar(
      BuildContext context, {
        required String content,
        Duration duration = const Duration(seconds: 2),
        Color backgroundColor = Colors.black87,
      }) {
    Flushbar(
      message: content,
      duration: duration,
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }
}
