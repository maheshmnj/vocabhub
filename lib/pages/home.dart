import 'package:flutter/material.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/services/supastore.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SupaStore supaStore = SupaStore();
  String query = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                onChanged: (x) {
                  setState(() {
                    query = x;
                  });
                },
                decoration: InputDecoration(hintText: "Search Word"),
              )),
          Expanded(
            child: FutureBuilder<List<Word>>(
                future: supaStore.findByWord(query),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Word>> snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, x) {
                        return ListTile(
                          title: Text('${snapshot.data![x].word}'),
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
