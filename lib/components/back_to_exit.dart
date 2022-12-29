import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> backToExit(BuildContext context)async{
  bool exitApp = await showCupertinoDialog(
      context: context,
      builder: (context){
        return CupertinoAlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
                child: Text('No'),
                onPressed: ()=>Navigator.of(context).pop(false)
            ),
            TextButton(
                child: Text('Yes'),
                onPressed: ()=>Navigator.of(context).pop(true)
            ),
          ],
        );
      }
  );
  return exitApp;
}