import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkTile extends StatelessWidget{

  final Widget widget;
  final String url;

  LinkTile({@required this.widget, @required this.url});

  @override
  Widget build(BuildContext context) {
    return ListTile (
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
          } else {
            Fluttertoast.showToast(
              msg: "Could not open link",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.0
            );
        }
      },
      title: widget,
    );
  }

}