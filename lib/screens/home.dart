import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String url = "https://owlbot.info/api/v4/dictionary/";
  final String token = "4da368d14109150eb0291884b18ab61c24364ae0";
  StreamController _streamController = StreamController();
  Stream _stream;
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  void _search() async {
    if (_textEditingController.text.isEmpty) {
      _streamController.add(null);
    }
    _streamController.add("waiting");
    var response = await get(url + _textEditingController.text,
        headers: {"Authorization": "Token " + token});
    print(response.body);
    _streamController.add(jsonDecode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My DIctionary"),
        centerTitle: true,
        bottom: PreferredSize(
            child: Container(
              child: Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      margin: EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: TextField(
                            controller: _textEditingController,
                          )),
                          IconButton(
                              icon: Icon(Icons.search), onPressed: _search)
                        ],
                      ))),
            ),
            preferredSize: Size.fromHeight(50)),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Text("Enter a text "),
                );
              }
              if (snapshot.data == "waiting") {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              // if (snapshot.data[0]["definitions"] == null ) {
              //   return Center(
              //     child: Text("No definitions found"),
              //   );
              // }
              return Container(
                child: Container(
                  child: ListView.builder(
                      itemCount: snapshot.data["definitions"].length,
                      itemBuilder: (context, i) => ListBody(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(8),
                                color: Colors.grey[300],
                                child: ListTile(
                                  leading: snapshot.data["definitions"][i]
                                              ["image_url"] ==
                                          null
                                      ? null
                                      : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              snapshot.data["definitions"][i]
                                                  ["image_url"]),
                                        ),
                                  title: Text(_textEditingController.text +
                                      " (${snapshot.data["definitions"][i]["type"].toString()})"),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                    " (${snapshot.data["definitions"][i]["definition"].toString()})"),
                              )
                            ],
                          )),
                ),
              );
            }),
      ),
    );
  }
}
