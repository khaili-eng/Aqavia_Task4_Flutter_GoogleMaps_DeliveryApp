import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SnackbarType {success,error}
showAppSnackbar({
  required BuildContext context,
required SnackbarType type,
required String description,
}){
  switch(type){
    case SnackbarType.success :
      CherryToast.success(
        toastDuration: Duration(milliseconds: 2000),
        height: 70,
        toastPosition: Position.top,
        shadowColor: Colors.white,
        animationType: AnimationType.fromTop,
        displayCloseButton: false,
        backgroundColor: Colors.green.withAlpha(40),
        description: Text(description,style: TextStyle(color: Colors.green),
        ),
        title: Text("successful",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
      ).show(context);
      break;
    case SnackbarType.error :
      CherryToast.error(
        toastDuration: Duration(milliseconds: 3000),
        height: 70,
        toastPosition: Position.top,
        shadowColor: Colors.white,
        animationType: AnimationType.fromTop,
        displayCloseButton: false,
        backgroundColor: Colors.red.withAlpha(40),
        description: Text(
          description,
          style: TextStyle(
            color: Colors.red
          ),
        ),
        title: Text("Fail",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
      ).show(context);
  }
}