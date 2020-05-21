import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mywords/components/library.dart';
import 'package:mywords/components/sectionHeader.dart';

class WordTile extends StatefulWidget {

  final SingleWord word;
  final Function adder;
  const WordTile({Key key, this.word, this.adder}) : super(key: key);

  @override
  _WordTileState createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> with SingleTickerProviderStateMixin{

  bool _expanded = false;
  AnimationController _controller;

  @override
  Widget build(BuildContext context) {

    return Slidable (
      key: Key(widget.word.word.toString()),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      actions: <Widget>[
        widget.word.isInFavoriteList ? IconSlideAction(
          caption: 'delete',
          color: Colors.redAccent,
          icon: Icons.delete,
        ) : IconSlideAction(
          caption: 'like',
          color: Colors.blueAccent,
          icon: Icons.favorite,
          onTap: () {
            widget.adder(widget.word);
          },
        )
      ],
      child:ExpansionTile(
        key: Key(widget.word.word.toString()),
        onExpansionChanged: (isExpanded){
          setState(() {
            _expanded = isExpanded;
          });
        },
        leading: Container(
          margin: EdgeInsets.only(top: 1, bottom: 1),
          child: SvgPicture.string(
            Jdenticon.toSvg(widget.word.word),
            fit: BoxFit.contain),
        ),
        title: Text(widget.word.word),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: "Meaning", definition: widget.word.definition, ),
            ],
          )
        ],
      )
    );
  }
}