final class Route {
  final String path;
  final String name;

  Route({required String name})
      : path = _makePath(name),
        name = _makeName(name);

  static String _makePath(String path) => '/$path';

  static String _makeName(String name) => '${name}_page';
}
