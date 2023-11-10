import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools;

extension Log on Object {
  void log() => devtools.log(toString());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final PersonURL url;
  const LoadPersonAction({required this.url}) : super();
}

enum PersonURL { person1, person2 }

extension URLString on PersonURL {
  String get urlString {
    switch (this) {
      case PersonURL.person1:
        return "http://127.0.0.1:5500/lib/api/person1.json";
      case PersonURL.person2:
        return "http://127.0.0.1:5500/lib/api/person2.json";
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  Person.fromJSON(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
}

Future<Iterable<Person>> getPeople(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJSON(e)));

@immutable
class FetchResult {
  final Iterable<Person> people;
  final bool isRetrievedFromCache;

  const FetchResult({required this.people, required this.isRetrievedFromCache});

  @override
  String toString() =>
      'Fetch Result (isRetriedFromCache = $isRetrievedFromCache), people = $people';
}

class PeopleBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonURL, Iterable<Person>> cache = {};
  PeopleBloc() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      final url = event.url;
      if (cache.containsKey(url)) {
        final cachedPeople = cache[url];
        final result =
            FetchResult(people: cachedPeople ?? {}, isRetrievedFromCache: true);
        emit(result);
      } else {
        final people = await getPeople(url.urlString);
        cache[url] = people;
        final result = FetchResult(people: people, isRetrievedFromCache: false);
        emit(result);
      }
    });
  }
}

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
                  context
                      .read<PeopleBloc>()
                      .add(LoadPersonAction(url: PersonURL.person1));
                },
                child: Text("Load JSON 1"),
              ),
              TextButton(
                onPressed: () {
                  context
                      .read<PeopleBloc>()
                      .add(LoadPersonAction(url: PersonURL.person2));
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
              print("People were empty");
              return const SizedBox();
            }
            print("People were not empty");
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
