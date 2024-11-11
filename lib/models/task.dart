import 'package:isar/isar.dart';

part 'task.g.dart';


@collection
class Task {
  Task({required this.name, required this.closed});

  Id id = Isar.autoIncrement;
  String name;
  bool closed;
}
