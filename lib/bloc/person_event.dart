part of 'person_bloc.dart';

@freezed
class PersonEvent with _$PersonEvent {
  const factory PersonEvent.getPersons() = _GetPersons;
  const factory PersonEvent.syncData() = _SyncData;
  const factory PersonEvent.add({required Person personRequest}) = _Add;
}
