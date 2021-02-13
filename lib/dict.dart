import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dictionary extends StatefulWidget {
  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic> map;
  List<dynamic> list;
  bool isLoading = false;
  bool noMeaningFound = false;

  sendData() async {
    print(searchController.text);
    final response = await http.get(
        "https://owlbot.info/api/v4/dictionary/" + searchController.text,
        headers: {
          "Authorization": "Token " +
              // Generate your Token API from https://owlbot.info/
              "Place your Token API here"
        });
    print(response.body);
    if (response.statusCode == 200) {
      map = json.decode(response.body);
      list = map["definitions"];
      print(list);
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        noMeaningFound = true;
      });
      throw Exception("Failed to load the data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Dictionary", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black),
        body: Column(children: <Widget>[
          Container(
            // color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                onChanged: (String text) {
                  print(text);
                  sendData();
                  setState(() {
                    noMeaningFound = false;
                    isLoading = true;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Search for a word",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)))),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: Container(
              child: (searchController.text.isEmpty)
                  ? Center(child: Text("Enter a word"))
                  : (noMeaningFound)
                      ? Center(child: Text("Oops! No meaning found!"))
                      : (isLoading)
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, i) {
                                return ListBody(children: [
                                  ListTile(
                                      leading: (list[i]["image_url"] != null)
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  list[i]["image_url"]))
                                          : null,
                                      title: Text(map["word"] +
                                          " (" +
                                          list[i]["type"] +
                                          ")")),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, 6.0, 12.0, 6.0),
                                    child: Text(list[i]["definition"]),
                                  ),
                                  Divider()
                                ]);
                              }),
            ),
          )
        ]));
  }
}
