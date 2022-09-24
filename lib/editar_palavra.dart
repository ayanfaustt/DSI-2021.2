import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Arguments {
  final WordPair name;
  Arguments(this.name);
}

class Repository {
  Iterable<WordPair> word;
  Repository(this.word);
}



class Editar extends StatefulWidget {
  static const routeName = '/editar';

  const Editar({super.key});

  @override
  State<Editar> createState() => _EditarState();
}

class _EditarState extends State<Editar> {

  

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Palavras'),
      ),
      body: Column(
        children: [
          const Center(
            child:  Text("Palavra editada:",
              style: TextStyle(fontSize: 20)
            ),
          ),
          Center(
            child: Text(arguments.name.asPascalCase,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ],
      ),
    );
  }
}