enum ChangeType {
  added('ADDED'),
  removed('REMOVED'),
  updated('UPDATED');

  const ChangeType(this.name);
  final String name;

  static const sorted = [
    ChangeType.added,
    ChangeType.removed,
    ChangeType.updated,
  ];
}
