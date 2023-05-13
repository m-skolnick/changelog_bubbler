enum DependencyType {
  directMain('direct main'),
  transitiveMain('transitive main'),
  directDev('direct dev'),
  transitiveDev('transitive dev');

  const DependencyType(this.name);
  final String name;

  static const sorted = [
    DependencyType.directMain,
    DependencyType.transitiveMain,
    DependencyType.directDev,
    DependencyType.transitiveDev,
  ];
}
