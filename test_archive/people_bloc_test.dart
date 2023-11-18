import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_bloc/bloc/bloc_actions.dart';
import 'package:learning_bloc/bloc/person.dart';
import 'package:learning_bloc/bloc/person_bloc.dart';

const mockPerson1 = [
  Person(name: "Foo", age: 20),
  Person(name: "Bar", age: 30),
];
const mockPerson2 = [
  Person(name: "Foo", age: 20),
  Person(name: "Bar", age: 30),
];

Future<Iterable<Person>> mockGetPerson1(String url) =>
    Future.value(mockPerson1);
Future<Iterable<Person>> mockGetPerson2(String url) =>
    Future.value(mockPerson2);

void main() {
  group("testing bloc", () {
    //write tests
    late PeopleBloc bloc;

    setUp(() => {
          bloc = PeopleBloc(),
        });

    blocTest<PeopleBloc, FetchResult?>(
      "Test initial state",
      build: () => bloc,
      verify: (bloc) => expect(bloc.state, null),
    );

    //fetch mock data (person1) and compare it with FetchResult
    blocTest(
      'Retrieving people from first Iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(LoadPersonAction(url: 'dummy_url1', loader: mockGetPerson1));
        bloc.add(LoadPersonAction(url: 'dummy_url1', loader: mockGetPerson1));
      },
      expect: () {
        FetchResult(people: mockPerson1, isRetrievedFromCache: false);
        FetchResult(people: mockPerson1, isRetrievedFromCache: true);
      },
    );
  });
}
