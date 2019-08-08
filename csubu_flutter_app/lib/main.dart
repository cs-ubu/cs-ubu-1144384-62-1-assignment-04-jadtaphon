import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {

  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(new CSUBUFlutterApp());

}

class CSUBUFlutterApp extends StatelessWidget {

  final appTitle = 'Premier League 2019';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //fontFamily: 'Roboto'
      ),
      home: AppHomePage(title: appTitle),
    );
  }

}

class AppHomePage extends StatefulWidget {

  AppHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppHomePageState createState() => _AppHomePageState();

}

class _AppHomePageState extends State<AppHomePage> {

  int _counter = 0;
  var _courses = <dynamic>[ ];
  // Future<dynamic> _students;
  var _students = [];
  var _loading = true;
  var _page = 0;

  _getStudents() async {
    var url = 'http://cs.sci.ubu.ac.th:7512/topic-1/Jadtaphon_59110440112/_search?from=${_page*10}&size=10';
    const headers = { 'Content-Type': 'application/json; charset=utf-8' };
    const query = { 'query': { 'match_all': {} } };
    final response = await http.post(url, headers: headers, body: json.encode(query));
    _students = [];
    if (response.statusCode == 200) {
      var result = jsonDecode(utf8.decode(response.bodyBytes))['result']['hits'];
      result.forEach((item) {
        if (item.containsKey('_source')) {
          var source = item['_source'];
          if (source.containsKey('name') && source.containsKey('score')&& source.containsKey('image')&& source.containsKey('Stadium')) {
            _students.add(item['_source']);
          }
        }
      });
    }
    setState(() {
      _page = (_page+1)%3;
      _loading = false;
    });
  }

  void _incrementCounter() {
    setState(() { _loading = true; });
    _getStudents();
  }

  Widget studentWidgets(BuildContext context) {
    return ListView.separated(
        itemCount: _students.length,
        padding: const EdgeInsets.all(8.0),
        separatorBuilder: (context, i) => const Divider(),
        itemBuilder: (context, i) {
          final student = _students[i];
          var sum = 0;
          student['name'].runes.forEach((c) { sum += c; });
          return ListTile(
            title: Row(
                  children: <Widget>[
                     Image.network('${student["image"]}', width: 45, height: 45),
                    //CircleAvatar(backgroundImage: NetworkImage('${student["image"]}')),
                    Expanded(child: Text(' '+student["name"]))
                  ]
                ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Stadium : ${student["Stadium"]}'),
                Text('Score : ${student["score"]}')
              ]
             )
          );
        }
      );
  }

  Widget loadingWidget(BuildContext context) {
    return Column(children: <Widget>[Text('loading....'), CircularProgressIndicator(), Text('Click the button')]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: (_loading)? loadingWidget(context) : studentWidgets(context),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(height: 50.0,),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Text('$_page'), // Icon(Icons.add),
      )
    );
  }
}
