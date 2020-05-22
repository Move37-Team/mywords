import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SectionHeader extends StatelessWidget{
  final String title;
  final String content;

  const SectionHeader({Key key, this.title, this.content}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 25, left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(
                fontSize: 15
              ),
            ),
            Divider(),

            Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(maxHeight: 250,),
              child: SingleChildScrollView(
                child: Text(content == null ? " " : content))
            )
          ],
        )
    );
  }

}