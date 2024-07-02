// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sync/bloc/person_bloc.dart';
import 'package:flutter_sync/helper/database_helper.dart';
import 'package:flutter_sync/model/person.dart';
import 'package:intl/intl.dart';

import '../helper/syncronize.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameC = TextEditingController();
  TextEditingController ageC = TextEditingController();
  TextEditingController genderC = TextEditingController();

  @override
  void initState() {
    DatabaseHelper().init();

    context.read<PersonBloc>().add(const PersonEvent.getPersons());
    super.initState();
  }

  @override
  void dispose() {
    nameC.dispose();
    ageC.dispose();
    genderC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Offline - Online Sync',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              bool connection = await SyncData.hasInternetConnection();

              if (!connection) {
                EasyLoading.showError('No Internet Connection');
              } else {
                context.read<PersonBloc>().add(const PersonEvent.syncData());
              }
            },
            icon: const Icon(Icons.replay_outlined),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Person',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: nameC,
              decoration: const InputDecoration(hintText: 'Name'),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
            TextField(
              controller: ageC,
              decoration: const InputDecoration(hintText: 'Age'),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
            TextField(
              controller: genderC,
              decoration: const InputDecoration(hintText: 'Gender'),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
            const SizedBox(height: 14),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<PersonBloc>().add(
                        PersonEvent.add(
                          personRequest: Person(
                            name: nameC.text,
                            age: int.parse(ageC.text),
                            gender: genderC.text,
                            createdAt: DateTime.now().toString(),
                          ),
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () async {
                  bool hasInternetConnection = await SyncData.hasInternetConnection();

                  if (hasInternetConnection) {
                    EasyLoading.showSuccess('Connect to Internet', duration: const Duration(seconds: 3));
                  } else {
                    EasyLoading.showError('No Internet Connection', duration: const Duration(seconds: 3));
                  }
                },
                child: const Text(
                  'Check Internet Connection',
                  style: TextStyle(
                    color: Colors.indigo,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('List Person'),
            const Divider(),
            BlocConsumer<PersonBloc, PersonState>(
              listener: (context, state) {
                state.maybeWhen(
                  orElse: () {},
                  failed: (message) => EasyLoading.showError(message),
                  loading: () => EasyLoading.show(status: 'Syncing data...'),
                  success: (persons, message) {
                    setState(() {
                      nameC.text = '';
                      ageC.text = '';
                      genderC.text = '';
                      EasyLoading.showSuccess(
                        message,
                        duration: const Duration(seconds: 3),
                      );
                    });
                  },
                );
              },
              builder: (context, state) {
                print(state);
                return state.maybeWhen(
                    orElse: () => const SizedBox.shrink(),
                    failed: (message) => Text(message),
                    success: (persons, message) {
                      if (persons.isEmpty) {
                        return const Text('Data person is empty');
                      } else {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: persons.length,
                            itemBuilder: (context, index) {
                              Person person = persons[index];
                              return ListTile(
                                title: Text(person.name),
                                subtitle: Text('Age : ${person.age}'),
                                trailing: Text(
                                  DateFormat('yyyy-MM-dd, HH:mm').format(
                                    DateTime.parse(
                                      person.createdAt,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    });
              },
            )
          ],
        ),
      ),
    );
  }
}
