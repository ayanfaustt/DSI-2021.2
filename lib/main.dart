import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startup_namer/editar_palavra.dart';

void main() {
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
  final List<WordPair> repo = Repository(generateWordPairs().take(20)).word.toList();
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  bool gridMode = false;
  int wordCount = 20;

  Widget _buildRow(WordPair pair, int index) {
    final alreadySaved = _saved.contains(pair);
    return InkWell(
      onTap: () => {
        Navigator.pushNamed(context, "/editar",
        arguments: Arguments(repo[index]) )
      },

      child: ListTile(
        title: Text(
          pair.asPascalCase,
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
                    repo.removeAt(index);
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
                  pair.asPascalCase,
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
              itemCount: repo.length,
              itemBuilder: (context, int i) {
                // if (i >= _suggestions.length) {
                //   _suggestions.addAll(generateWordPairs().take(10));
                // }

                // return _buildRow(_suggestions[i], i);
                return _buildRow(repo.elementAt(i), i);
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
