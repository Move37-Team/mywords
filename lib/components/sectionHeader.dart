import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SectionHeader extends StatelessWidget{
  final String title;

  const SectionHeader({Key key, this.title}) : super(key: key);
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

            SingleChildScrollView(
              child: Container(
                height: 50,
                child: Text("""Simple succession, or the coming after in time, withoutasserting or implying causative energy; as, the reactions of chemicalagents may be conceived as merely invariable sequences."""),
              )
            )
          ],
        )
    );
  }

}