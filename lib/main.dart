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
import 'package:tuple/tuple.dart';

import 'components/debounce.dart';

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
  bool _dictLoaded = false;                                               // if dictionary is loaded
  Widget _floatingActionWidget;                                           // the add button
  Map<String, dynamic> _dictionary;                                       // the global dictionary
  RefreshController _refreshController =                                  // refresh controller
  RefreshController(initialRefresh: true);
  final _debounce = Debounce(milliseconds: 500);                          // search field debounce

  _MyHomePageState() {
    _loadDict();
  }

  Future<void> _loadDict() async {
    // load english dictionary from json asset
    // load and parse json dictionary
    String jsonString =  await rootBundle.loadString("assets/dictionary_web.json");

    setState(() {
      _dictionary = jsonDecode(jsonString);
    });

    TrieNode.roots = await compute(TrieNode.makeTrieFromDict, _dictionary);

    setState(() {
      _dictLoaded = true;
    });

  }

  void searchAndUpdateList(String word) {
    // search for the given word in the dictionary and show relevant results
    if (!_dictLoaded || word.length == 0)
      return;

    List<SingleWord> wordsFound = List();
    TrieNode root;

    try {
      root = TrieNode.roots.firstWhere((element) => element.char == word[0]);
    } catch (E) {
      setState(() {
        _showingWords = wordsFound;
      });

      return;
    }

    // traverse the word tree up to the given word first
    TrieNode currentNode = root;
    for (var i = 1 ; i < word.length; i ++) {
      try {
        currentNode = currentNode.next.firstWhere((element) => element.char == word[i]);
      } catch (E) {
        setState(() {
          _showingWords = wordsFound;
        });

        return;
      }
    }

    if (currentNode.isWord)
      wordsFound.add(SingleWord(word, _dictionary[word]));

    setState(() {
      _showingWords = wordsFound;
    });

    return;

    // find all the possible words starting from this word
    List<Tuple2<String, TrieNode>> stack = List();

    currentNode.next.forEach((element) {
      stack.add(Tuple2(word, element));
    });

    while(stack.length > 0) {
      var top = stack[stack.length - 1];
      stack.removeLast();
      String newBaseWord = top.item1 + top.item2.char;

      if (top.item2.isWord) {
        wordsFound.add( SingleWord( newBaseWord, _dictionary[newBaseWord]) );
      }

      top.item2.next.forEach((element) {
        stack.add(Tuple2(newBaseWord, element));
      });
    }

    setState(() {
      _showingWords = wordsFound;
    });
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
                  enabled: _dictLoaded ? true : false,
                  controller: _wordTextController,
                  onChanged: (text) {
                    _debounce.run(() {
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
                    });
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "WorkSansLight",
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: _dictLoaded ? 'Enter a word to search or add' : 'Loading dictionary ...',
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
                          key: Key(_showingWords[index].word),
                          child: WordTile(title: Text(_showingWords[index].word), definition: _showingWords[index].definition,  )
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
