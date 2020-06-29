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

  bool _requesting = false;
  Future<Response> _onTimeout(context) {
    // Scaffold.of(context).showSnackBar(SnackBar(
    //   content: Text("Server timeout"),
    // ));
    print("timeout");
  }

  void _search() async {
    _requesting = true;
    if (_textEditingController.text.isEmpty) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    Response response = await get(url + _textEditingController.text,
        headers: {"Authorization": "Token " + token}).catchError((err) {
      print(err);
    }).timeout(Duration(seconds: 10), onTimeout: () {
      _onTimeout(context);
      return;
    });
    if (response == null) {
      _streamController.add("timeout");
      return;
    }
    if (response.statusCode == 404) {
      print("fkgf");
      _streamController.add("No definitions");
      return;
    }
    // print(json.decode(response.body);
    // if (jsonDecode(response.body)[0]["message"] == "No definition :(") {
    //   print("no");
    //   _streamController.add("No Definitions");
    // }
    _streamController.add(jsonDecode(response.body));
  }

  // void _onTextChanged(String value) {
  //   Timer(Duration(seconds: 3), () {
  //     if (!_requesting) {
  //       print(value);
  //       _search();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My DIctionary",
          style:
              TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold),
        ),
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
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: TextField(
                            // onChanged: _onTextChanged,
                            style: TextStyle(fontFamily: "Montserrat"),
                            decoration: InputDecoration.collapsed(
                                hintText: "Enter text here",
                                hintStyle: TextStyle(
                                    fontFamily: "Montserrat",
                                    color: Colors.black38)),
                            controller: _textEditingController,
                          )),
                          Builder(
                              builder: (context) => IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () => _search()))
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
              if (snapshot.data == "timeout") {
                return Center(
                  child: Text("timeout"),
                );
              }
              if (snapshot.data == "No definitions") {
                // print("entered");
                return Center(
                  child: Text(
                      "No Definitions found for ${_textEditingController.text}"),
                );
              }
              print(snapshot.data);
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
                                  trailing: IconButton(
                                      icon: Icon(Icons.add), onPressed: () {}),
                                  leading: snapshot.data["definitions"][i]
                                              ["image_url"] ==
                                          null
                                      ? null
                                      : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              snapshot.data["definitions"][i]
                                                  ["image_url"]),
                                        ),
                                  title: Text(
                                    "${(i + 1).toString()}. " +
                                        _textEditingController.text +
                                        " (${snapshot.data["definitions"][i]["type"].toString()})",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "${snapshot.data["definitions"][i]["definition"].toString()}",
                                  style: TextStyle(
                                      fontFamily: "Montserrat", fontSize: 15),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                    text: "Example:  ",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 15,
                                        color: Colors.blue),
                                  ),
                                  TextSpan(
                                    text:
                                        "${snapshot.data["definitions"][i]["example"].toString()}",
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: 15,
                                        color: Colors.black),
                                  ),
                                ])),
                              ),
                            ],
                          )),
                ),
              );
            }),
      ),
    );
  }
}
