import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc/bloc/bloc_actions.dart';
import 'dart:developer' as devtools;

import 'package:learning_bloc/bloc/person.dart';
import 'package:learning_bloc/bloc/person_bloc.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<Iterable<Person>> getPeople(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJSON(e)));

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<PeopleBloc>().add(
                      LoadPersonAction(url: person1URL, loader: getPeople));
                },
                child: Text("Load JSON 1"),
              ),
              TextButton(
                onPressed: () {
                  context.read<PeopleBloc>().add(
                      LoadPersonAction(url: person2URL, loader: getPeople));
                },
                child: Text("Load JSON 2"),
              ),
            ],
          ),
          BlocBuilder<PeopleBloc, FetchResult?>(
              buildWhen: (previousResult, currentResult) {
            return previousResult?.people != currentResult?.people;
          }, builder: (context, fetchResult) {
            final people = fetchResult?.people;
            fetchResult?.log();
            if (people == null) {
              return const SizedBox();
            }
            return Expanded(
              child: ListView.builder(
                  itemCount: people.length,
                  itemBuilder: ((context, index) {
                    final person =
                        people[index] ?? Person(name: "name", age: 10);
                    return ListTile(title: Text(person.name));
                  })),
            );
          })
        ],
      ),
    );
  }
}
