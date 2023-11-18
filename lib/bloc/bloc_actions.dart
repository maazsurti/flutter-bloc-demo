import 'package:flutter/foundation.dart';
import 'package:learning_bloc/bloc/person.dart';

const person1URL = "http://127.0.0.1:5500/lib/api/person1.json";
const person2URL = "http://127.0.0.1:5500/lib/api/person2.json";

typedef PersonLoader = Future<Iterable<Person>> Function(String url);

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final String url;
  final PersonLoader loader;
  const LoadPersonAction({required this.url, required this.loader}) : super();
}
