part of 'person_bloc.dart';

@freezed
class PersonState with _$PersonState {
  const factory PersonState.initial() = _Initial;
  const factory PersonState.loading() = _Loading;
  const factory PersonState.success({required List<Person> persons, required String message}) = _Success;
  const factory PersonState.failed({required String message}) = _Failed;
}
