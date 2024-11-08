class Task {
  Task({
    required this.id, required this.name, required this.closed
  });

  final int id;
  final String name;
  final bool closed;
}

List<Task> tasks = [
  Task(id: 1, name: 'aaa', closed: true),
  Task(id: 2, name: 'bbb', closed: false),
  Task(id: 3, name: 'ccc', closed: false),
];