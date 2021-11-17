import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter/cupertino.dart';

showCustomDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  Color? backgroundColor,
  required List<String> buttonActions,
  Color? buttonsColor,
  required VoidCallback onPressed1,
  required VoidCallback onPressed2,
}) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: backgroundColor ?? context.primaryColor,
        title: Text(title),
        content: Text(subtitle ?? ''),
        actions: <Widget>[
          MaterialButton(
            child: Text(buttonActions[0]),
            elevation: 5,
            textColor: buttonsColor ?? context.scaffoldBackgroundColor,
            onPressed: onPressed1,
          ),
          MaterialButton(
            child: Text(buttonActions[1]),
            elevation: 5,
            textColor: buttonsColor ?? context.scaffoldBackgroundColor,
            onPressed: onPressed2,
          ),
        ],
      ),
    );
  } else {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(subtitle ?? ''),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(buttonActions[0]),
            onPressed: onPressed1,
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(buttonActions[1]),
            onPressed: onPressed2,
          )
        ],
      ),
    );
  }
}

/// Muestra un mensaje de error
showErrorDialog(BuildContext context, String error, String description) {
  if (Platform.isAndroid) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(error),
        content: Text(description),
        actions: <Widget>[
          MaterialButton(
            child: const Text('Ok'),
            elevation: 5,
            textColor: Colors.blue,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  } else {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(error),
        content: Text(description),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// Muestra un Toast después de que el texto seleccionado se haya copiado en el Portapapeles.
Widget showToast(bool canShowToast, Alignment alignment, String toastText) {
  return Visibility(
      visible: canShowToast,
      child: Positioned.fill(
        bottom: 25.0,
        child: Align(
          alignment: alignment,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(
                    left: 16, top: 6, right: 16, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                child: Text(
                  toastText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ));
}
