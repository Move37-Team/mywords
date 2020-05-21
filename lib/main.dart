import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mywords/components/library.dart';
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
  Map<String, dynamic> _dictionary;                                       // the global dictionary
  Map<String, dynamic> _trieDict;                                         // the global dictionary keys in trie structure

  RefreshController _refreshController =                                  // refresh controller
  RefreshController(initialRefresh: true);
  final _debounce = Debounce(milliseconds: 500);                          // search field debounce

  _MyHomePageState() {
    _loadDict();
  }

  Future<bool> _loadDict() async {
    // load english dictionary from json asset
    // load and parse json dictionary
    String dictJsonString =  await rootBundle.loadString("assets/dictionary_web.json");
    String trieJsonString =  await rootBundle.loadString("assets/trie_dict.json");

    setState(() {
      _dictionary = jsonDecode(dictJsonString);
      _trieDict = jsonDecode(trieJsonString);
    });

    setState(() {
      _dictLoaded = true;
    });

  }

  Future<void> searchAndUpdateList(String word) async {
    // search for the given word in the dictionary
    // also shows every possible word starting with the given word
    // if nothing is found, the given word will be returned

    if (!_dictLoaded || word.length == 0)
      return;

    // search results
    List<SingleWord> wordsFound = List();

    // regardless of word being found, add it to the list
    wordsFound.add(
        SingleWord(
            word: word,
            definition: _dictionary[word],
            isInFavoriteList: _library.contains(word)
        )
    );

    // the node that the search starts with, it's based on the first character of the given word
    Map<String, dynamic> root;

    try {
      root = _trieDict[word[0]];
    } catch (E) {
      setState(() {
        _showingWords = wordsFound;
      });

      return;
    }

    // traverse the word tree up to the given word first
    Map<String, dynamic> currentNode = root;
    for (var i = 1 ; i < word.length; i ++) {
      try {
        currentNode = currentNode[word[i]];
      } catch (E) {
        setState(() {
          _showingWords = wordsFound;
        });

        return;
      }
    }



    // find all the possible words starting from this word
    List<Tuple2<String, Map<String, dynamic>> > stack = List();  // (baseWord, node)

    currentNode.keys.forEach((element) {
      if ( currentNode[element].runtimeType != String ) {
        stack.add(Tuple2(word + element, currentNode[element]));
      }
    });

    while(stack.length > 0) {
      // pop an item from the top of the stack
      var top = stack[stack.length - 1];
      stack.removeLast();

      if (top.item2.containsKey("_end_"))
        wordsFound.add(
          SingleWord(
            word: top.item1,
            definition: _dictionary[top.item1],
            isInFavoriteList: _library.contains(top.item1)
          )
        );

      // add the current nodes children with the new word as their baseWord to be checked
      top.item2.keys.forEach((element) {
        if ( top.item2[element].runtimeType != String ) {
          stack.add(Tuple2(top.item1 + element, top.item2[element]));
        }
      });
    }

    // update the show words list
    setState(() {
      _showingWords = wordsFound;
    });
  }

  Future<void> doRefresh() async {
    // if the search field is not empty refresh based on dictionary data
    if (_wordTextController.text.trim().length > 0) {
      await searchAndUpdateList(_wordTextController.text.trim().toLowerCase());

    } else {
      // if search filed is empty reload user's favorite words from database
      await _library.loadFromDatabase();

      // only update if everything is mounted
      setState(() {
        _showingWords = _library.words;
      });
    }
  }

  void _onRefresh() async{
    await doRefresh();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await doRefresh();
    _refreshController.loadComplete();
  }

  void _add(SingleWord word) {
    setState(() {
      word.isInFavoriteList = true;
      _library.addWord(word);
    });

    Fluttertoast.showToast(
        msg: "Added to library",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
                      }
                      else {
                        setState(() {
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
                          child: WordTile( word: _showingWords[index], adder: _add, )
                        );
                      },
                      itemCount: _showingWords.length,
                  )
                )
              )
            ],
          )
      ),
    );
  }
}
