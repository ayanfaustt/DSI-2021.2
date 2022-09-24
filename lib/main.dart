import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startup_namer/editar_palavra.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  final repo2 = Repository(generateWordPairs().take(20)).word.toList();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var storage = FirebaseFirestore.instance.collection('words');


  var count = 0;

  repo2.forEach((value){
    // print(value.first.runtimeType);
      storage.doc('$count').set({
        'word': value.first + value.second
      }); 
      count += 1; 

    }
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: RandomWords(),
      initialRoute: '/',
      routes: {
        // '/': (context) => const MyApp(),
        Editar.routeName:(context) => const Editar(),
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  static const routeName = '/';
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}



class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = [];
  final repo = Repository(generateWordPairs().take(20)).word.toList();
  final _biggerFont = const TextStyle(fontSize: 18);
  bool gridMode = false;
  int wordCount = 20;
  List<String> userData = [];

  @override
  void initState() {
    // TODO: implement initState
    _getUserData();
    super.initState();
  }


  _getUserData() async {
    // final ref = FirebaseDatabase.instance.ref('users/${id}');
    FirebaseFirestore.instance.collection('words').get().then((value){

      value.docs.toList().forEach((e){
        setState(() {
          userData.add(e.data().values.toString());
        });      
      });

      
    });
  }




  Future<dynamic> _builderDialog(BuildContext context, userData){

    var newWord;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const  Text('Criar nova Palavra'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                newWord = value;
              });
            },
          ),
          actions: [
            MaterialButton(
              elevation: 5.0,
              child: const Text("criar"),
              onPressed: (){
                setState(() {
                  // var aux = WordPair(newWord, '.');
                  // repo.add(aux);
                  userData.add(newWord);
                });
                var storage = FirebaseFirestore.instance.collection('words');
                storage.doc('${userData.length}').set({
                  'word': newWord
                }); 

              },
            )
          ],

        );
      }
    );
  }

  Widget _buildRow(String pair, int index) {
    final alreadySaved = _saved.contains(pair);
    return InkWell(
      onTap: () => {
        Navigator.pushNamed(context, "/editar",
        arguments: Arguments(repo[index]) )
      },

      child: ListTile(
        title: Text(
          pair,
          style: _biggerFont,
        ),
        trailing: Wrap(
          spacing: -15,
          children: <Widget>[
            IconButton(
              icon: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? Colors.red : null,
              ),
              tooltip: 'Save Name',
              onPressed: () {
                setState(() {
                  if (alreadySaved) {
                    _saved.remove(pair);
                  } else {
                    _saved.add(pair);
                  }
                });
              },
            ),
            IconButton(
                icon: const Icon(CupertinoIcons.delete),
                onPressed: () {
                  setState(() {
                    if (alreadySaved) {
                      _saved.remove(_suggestions[index]);
                    }
                    // _suggestions.removeAt(index);
                    // repo.removeAt(index);
                    userData.remove(pair);
                    var storage = FirebaseFirestore.instance.collection('words');
                    storage.doc('${userData.length}').delete(); 

                  });
                })
          ],
        ),
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Startup Name Generator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: "Saved Suggestions",
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
               _builderDialog(context, userData);
            },
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Card Mode',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: gridMode,
                  onChanged: (value) {
                    setState(() {
                      gridMode = value;
                    });
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: userData.length,
              itemBuilder: (context, int i) {
                // if (i >= _suggestions.length) {
                //   _suggestions.addAll(generateWordPairs().take(10));
                // }

                // return _buildRow(_suggestions[i], i);
                print('tamanho: ${userData.length}');
                print(i);
                return _buildRow(userData.elementAt(i), i);
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridMode ? 2 : 1,
                mainAxisExtent: 75,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
