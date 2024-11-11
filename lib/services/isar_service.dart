import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  //Save a new task to the Isar database.
  Future<void> saveTask(Task newTask) async {
    final isar = await db;
    //Perform a synchronous write transaction to add the task to the database.
    isar.writeTxnSync(() => isar.tasks.putSync(newTask));
  }
    //Listen to changes in the task collection and yield a stream of task lists.
  Stream<List<Task>> listenTask() async* {
    final isar = await db;
    //Watch the user collection for changes and yield the updated user list.
    yield* isar.tasks.where().watch(fireImmediately: true);
  }

  Future<Isar> openDB() async {
    var dir = await getApplicationDocumentsDirectory();
    
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        // task.g.dart includes the schemes that we need to define here - it can be multiple.
        [TaskSchema],
        directory: dir.path,
      );
    }

    // return instance of Isar - it makes the isar state Ready for Usage for adding/deleting operations.
    return Future.value(Isar.getInstance());
  }
}