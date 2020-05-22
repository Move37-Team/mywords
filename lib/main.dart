import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mywords/components/library.dart';
import 'package:mywords/components/wordTIle.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'components/debounce.dart';
import 'components/dictionary.dart';

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
  Dictionary _dictionary;                                                 // actual english dictionary
  RefreshController _refreshController =                                  // refresh controller
  RefreshController(initialRefresh: true);
  final _debounce = Debounce(milliseconds: 500);                          // search field debounce

  @override
  initState() {
    super.initState();

    _dictionary = Dictionary(callback: () { setState(() {}); });

  }


  Future<void> doRefresh() async {
    // if the search field is not empty refresh based on dictionary data
    if (_wordTextController.text.trim().length > 0) {
      setState(() {
        _showingWords = _dictionary.searchAndUpdateList(_wordTextController.text.trim().toLowerCase());
      });
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

  void _remove(SingleWord word) {
    setState(() {
      word.isInFavoriteList = false;
      _library.removeWord(word);
    });

    Fluttertoast.showToast(
        msg: "Removed from library",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orangeAccent,
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
                  enabled: _dictionary.loaded ? true : false,
                  controller: _wordTextController,
                  onChanged: (text) {
                    _debounce.run(() {
                      if (_wordTextController.text.length > 0){
                        setState(() {
                          _showingWords = _dictionary.searchAndUpdateList(_wordTextController.text.trim().toLowerCase());

                        });
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
                    hintText: _dictionary.loaded ? 'Enter a word to search or add' : 'Loading dictionary ...',
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
                        _showingWords[index].isInFavoriteList = _library.contains(_showingWords[index].word);
                        return Card(
                          key: Key(_showingWords[index].word),
                          child: WordTile( word: _showingWords[index], adder: _add, remover: _remove,)
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
