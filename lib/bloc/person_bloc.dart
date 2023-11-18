import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc/bloc/bloc_actions.dart';
import 'package:learning_bloc/bloc/person.dart';

class PeopleBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> cache = {};
  PeopleBloc() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      final url = event.url;
      if (cache.containsKey(url)) {
        final cachedPeople = cache[url];
        final result =
            FetchResult(people: cachedPeople ?? {}, isRetrievedFromCache: true);
        emit(result);
      } else {
        final loader = event.loader;
        final people = await loader(url);
        cache[url] = people;
        final result = FetchResult(people: people, isRetrievedFromCache: false);
        emit(result);
      }
    });
  }
}

@immutable
class FetchResult {
  final Iterable<Person> people;
  final bool isRetrievedFromCache;

  const FetchResult({required this.people, required this.isRetrievedFromCache});

  @override
  String toString() =>
      'Fetch Result (isRetriedFromCache = $isRetrievedFromCache), people = $people';

  @override
  bool operator ==(covariant FetchResult other) =>
      people.isEqualToIgnoringOrdering(other.people) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(people, isRetrievedFromCache);
}

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({other}).length == length;
}
