import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mywords/components/sectionHeader.dart';

var helloInfo = {
  "MEANINGS": {
    "3": ["Noun", "a hard steel edge tool used to cut gears", ["Edge tool"], []],
    "4": ["Noun", "a shelf beside an open fire where something can be kept warm", ["Shelf"], []],
    "1": ["Verb", "cut with a hob", ["Cut"], []]
  },
  "ANTONYMS": [],
  "SYNONYMS": ["Hob", "Gremlin", "Elf", "Imp", "Hobgoblin"]
};


class WordTile extends StatefulWidget {

  final Widget title;               // tile title

  const WordTile({Key key, this.title}) : super(key: key);

  @override
  _WordTileState createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> with SingleTickerProviderStateMixin{

  bool _expanded = false;
  AnimationController _controller;
  Widget _wordIdenticon;

  @override
  void initState() {
    super.initState();

    String rawSvg = Jdenticon.toSvg(widget.title.toString());
    _wordIdenticon = SvgPicture.string(rawSvg, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {

    return Slidable (
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        actions: <Widget>[
          IconSlideAction(
            caption: 'delete',
            color: Colors.redAccent,
            icon: Icons.delete,
          ),
        ],
        child:ExpansionTile(
        onExpansionChanged: (isExpanded){
          setState(() {
            _expanded = isExpanded;
          });
        },
        leading: Container(
          margin: EdgeInsets.only(top: 1, bottom: 1),
          child: _wordIdenticon,
        ),
        title: widget.title,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: "Meaning"),
            ],
          )
        ],
      )
    );
  }
}