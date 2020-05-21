import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mywords/components/library.dart';
import 'package:mywords/components/wordTIle.dart';

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
  final _wordTextController = TextEditingController();
  void _add() {

  }

  Widget _floatingActionWidget;



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
                controller: _wordTextController,
                onChanged: (text) => {
                  setState(() => {
                    if (text.length > 0){
                      _floatingActionWidget = FloatingActionButton(
                        onPressed: () => {},
                        child: Icon(Icons.add,),
                      )
                    } else {
                      _floatingActionWidget = null
                    }
                  })
                },
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "WorkSansLight",
                ),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: 'Enter a word to search or add',
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
              child: ListView.builder(itemBuilder: (BuildContext context, int index) {
                if (index > 10)
                  return null;
                return Card(
                  child: WordTile(title: Text("hello"),)
                );
              },)
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
