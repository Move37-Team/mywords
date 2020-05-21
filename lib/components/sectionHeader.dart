import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SectionHeader extends StatelessWidget{
  final String title;
  final String definition;

  const SectionHeader({Key key, this.title, this.definition}) : super(key: key);
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
              height: 100,
              child: SingleChildScrollView(
                child: Text(definition == null ? " " : definition))
            )
          ],
        )
    );
  }

}