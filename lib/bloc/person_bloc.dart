import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../helper/database_helper.dart';
import '../helper/syncronize.dart';
import '../model/person.dart';

part 'person_event.dart';
part 'person_state.dart';
part 'person_bloc.freezed.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  PersonBloc() : super(const _Initial()) {
    List<Person> currentPersons = [];

    on<_GetPersons>((event, emit) async {
      emit(const _Loading());
      List<Person> personsFromLocal = await DatabaseHelper().getPersons();

      final response = await http.get(Uri.parse('http://syncdata-api.test/api/persons'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      List personsMap = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Person> personsResult = List.from(personsMap.map((e) => Person.fromJson(e)));
        currentPersons = [...personsFromLocal.reversed, ...personsResult.reversed];
        emit(_Success(persons: currentPersons, message: 'Success Get Persons...'));
      } else {
        emit(_Failed(message: response.reasonPhrase!));
      }
    });

    on<_SyncData>((event, emit) async {
      emit(const _Loading());
      List<Person> personsFromLocal = await DatabaseHelper().getPersons();

      if (personsFromLocal.isNotEmpty) {
        for (var i = 0; i < personsFromLocal.length; i++) {
          Map<String, dynamic> personRequest = {
            "name": personsFromLocal[i].name,
            "age": personsFromLocal[i].age,
            "gender": personsFromLocal[i].gender,
            "created_at": personsFromLocal[i].createdAt,
          };

          final response = await http
              .post(Uri.parse('http://syncdata-api.test/api/persons'), body: jsonEncode(personRequest), headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          });

          if (response.statusCode == 200) {
            emit(_Success(persons: currentPersons, message: 'Success sync data...'));
            DatabaseHelper().deletePerson(personsFromLocal[i].id!);
          } else {
            emit(_Failed(message: response.reasonPhrase!));
          }
        }
      } else {
        emit(_Success(persons: currentPersons, message: 'No data to sync...'));
      }
    });

    on<_Add>((event, emit) async {
      emit(const _Loading());
      bool connection = await SyncData.hasInternetConnection();

      if (connection) {
        Map<String, dynamic> personRequest = {
          "name": event.personRequest.name,
          "age": event.personRequest.age,
          "gender": event.personRequest.gender,
          "created_at": event.personRequest.createdAt,
        };

        final response = await http.post(
          Uri.parse('http://syncdata-api.test/api/persons'),
          body: jsonEncode(personRequest),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        Person newPerson = Person.fromJson(jsonDecode(response.body));

        if (response.statusCode == 200) {
          currentPersons.insert(0, newPerson);
          emit(_Success(persons: currentPersons, message: 'Success add person to Online DB'));
        } else {
          emit(_Failed(message: response.reasonPhrase!));
        }
      } else {
        var personId = await DatabaseHelper().insertToLocal(event.personRequest);
        var personToLocalResult = await DatabaseHelper().getPersons();
        var newPerson = personToLocalResult.firstWhere((element) => element.id == personId);

        currentPersons.insert(0, newPerson);
        emit(_Success(persons: currentPersons, message: 'Success add person to Local DB'));
      }
    });
  }
}
