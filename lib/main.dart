import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mywords/components/library.dart';
import 'package:mywords/components/trie.dart';
import 'package:mywords/components/wordTIle.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Words!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'My Words!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final WordLibrary _library = WordLibrary();                             // user's custom words selection library
  final _wordTextController = TextEditingController();                    // search text field controller
  List<SingleWord> _showingWords = List();                                // list of the words that are shown in the list view
  Map<String, dynamic> _dictionary;                                       // english dictionary
  bool dictLoaded = false;                                                // if dictionary is loaded
  Widget _floatingActionWidget;                                           // the add button
  RefreshController _refreshController =                                  // refresh controller
  RefreshController(initialRefresh: true);
  _MyHomePageState() {
    _loadDict();
  }

  Future<void> _loadDict() async {
    // load english dictionary from json asset
    // load and parse json dictionary
    String jsonString =  await rootBundle.loadString("assets/dictionary_web.json");
    _dictionary = jsonDecode(jsonString);

    TrieNode.roots = await compute(TrieNode.makeTrieFromDict, _dictionary);

    setState(() {
      dictLoaded = true;
    });

  }

  void searchAndUpdateList(String word) {
    // search for the given word in the dictionary and show relevant results
    if (!dictLoaded)
      return;

  }

  void _onRefresh() async{
    await _library.loadFromDatabase();
    _refreshController.refreshCompleted();
    setState(() {
      _showingWords = _library.words;
    });
  }

  void _onLoading() async{
    // monitor network fetch
    await _library.loadFromDatabase();
    if(mounted)
      setState(() {
        _showingWords = _library.words;
      });
    _refreshController.loadComplete();
  }

  void _add() {

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

      ),
      body: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  enabled: dictLoaded ? true : false,
                  controller: _wordTextController,
                  onChanged: (text) {
                    if (_wordTextController.text.length > 0){
                      searchAndUpdateList(text.trim().toLowerCase());
                      setState(() {
                        _floatingActionWidget = FloatingActionButton(
                          onPressed: () => {},
                          child: Icon(Icons.add,),
                        );
                      });
                    }
                    else {
                      setState(() {
                        _floatingActionWidget = null;
                        _showingWords = _library.words;
                      });
                    }
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "WorkSansLight",
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: dictLoaded ? 'Enter a word to search or add' : 'Loading dictionary ...',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(style: BorderStyle.solid, color: Colors.black12)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(style: BorderStyle.solid, color: Colors.black12)
                    ),
                    prefixIcon: Icon(
                      Icons.title,
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(
                        color: Colors.black38, fontFamily: "WorkSansLight"),
                    filled: true,
                  ),
                ),
              ),
              Expanded(
                  child: SmartRefresher(
                    controller: _refreshController,
                    header: WaterDropHeader(),
                    enablePullDown: true,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: ListView.builder (
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            child: WordTile(title: Text(_showingWords[index].word), )
                        );
                      },
                      itemCount: _showingWords.length,
                  )
                )
              )
            ],
          )
      ),

      floatingActionButton: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        // don't show the add button if no text typed
        child: _floatingActionWidget
      )
    );
  }
}
