import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mutex/mutex.dart';

import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import 'library.dart';

class Dictionary {
  /// An actual english dictionary
  /// consists of three parts
  /// 1 - Webster's Unabridged English Dictionary
  /// 2 - WordNet thesaurus - used for synonyms
  /// 3 - A trie structured list of words - used for fast word lookups
  /// all the files are in json format and in assets folder and
  /// will be loaded into native dart Maps

  bool _dictLoaded = false;                                               // if dictionary is loaded
  bool _trieLoaded = false;                                               // if trie dict file is loaded
  bool _synonymsLoaded = false;                                           // is synonym file is loaded
  bool _allLoaded = false;                                                // if all of the three dictionary files are loaded

  Map<String, dynamic> _dictionary;                                       // the global dictionary
  Map<String, dynamic> _trieDict;                                         // the global dictionary keys in trie structure
  Map<String, dynamic> _synonymsDict;                                     // dictionary of word synonyms

  Function callback;                                                     // when the dictionary is loaded into memory, this callback will be called
  Mutex m = Mutex();                                                     // used to ensure loaded statuses are set correctly

  get loaded => _allLoaded;

  Dictionary({ @required this.callback}) {
    _loadAll();
  }

  Future<void> _loadJson(String path, Function callback) async {
    // load and parse json from assets and return the results via callback
    String jsonString =  await rootBundle.loadString(path);
    Map<String, dynamic> dict = jsonDecode(jsonString);
    callback(dict);
  }

  void _updateAllLoadedStatus() async {
    await m.acquire();

    // set allLoaded
    _allLoaded = _dictLoaded && _trieLoaded && _synonymsLoaded;

    if (_allLoaded)
      callback();

    m.release();
  }


  void _loadAll() {
    // load all three dictionary files

    // load Webster's Unabridged English Dictionary
    _loadJson("assets/dictionary_web.json", (dict) {
      _dictLoaded = true;
      _dictionary = dict;
      _updateAllLoadedStatus();
    });

    // load trie file
    _loadJson("assets/trie_dict.json", (dict) {
      _trieLoaded = true;
      _trieDict = dict;
      _updateAllLoadedStatus();
    });

    // load synonyms file
    _loadJson("assets/synonyms_dict.json", (dict) {
      _synonymsLoaded = true;
      _synonymsDict = dict;
      _updateAllLoadedStatus();
    });

  }

  List<SingleWord> searchAndUpdateList(String word)  {
    // search for the given word in the dictionary
    // also shows every possible word starting with the given word
    // if nothing is found, the given word will be returned

    // search results
    List<SingleWord> wordsFound = List();

    if (!_allLoaded || word.length == 0)
      return wordsFound;

    // regardless of word being found, add it to the list
    wordsFound.add(
        SingleWord(
            word: word,
            definition: _dictionary[word],
            synonyms: _synonymsDict[word],
            // the flag is set to false, but one should change it the appropriate value upon using it
            // it's set to false because I want to keep the coupling with other classes to minimum
            isInFavoriteList: false
        )
    );

    // the node that the search starts with, it's based on the first character of the given word
    Map<String, dynamic> root;

    try {
      root = _trieDict[word[0]];
    } catch (E) {
      return wordsFound;
    }

    // traverse the word tree up to the given word first
    Map<String, dynamic> currentNode = root;
    for (var i = 1 ; i < word.length; i ++) {
      try {
        currentNode = currentNode[word[i]];
      } catch (E) {
        return wordsFound;
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
                synonyms: _synonymsDict[top.item1],
                definition: _dictionary[top.item1],
                isInFavoriteList: false
            )
        );

      // add the current nodes children with the new word as their baseWord to be checked
      top.item2.keys.forEach((element) {
        if ( top.item2[element].runtimeType != String ) {
          stack.add(Tuple2(top.item1 + element, top.item2[element]));
        }
      });
    }

    return wordsFound;
  }

  String meaningOf(String word) => _dictionary[word];
  String synonymsOf(String word) => _synonymsDict[word];

}