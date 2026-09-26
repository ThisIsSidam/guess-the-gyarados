import 'package:guessthegyarados/objectbox.g.dart';

class ObjectBoxStore {
  ObjectBoxStore(this.store);

  final Store store;

  static Future<ObjectBoxStore> create() async {
    return ObjectBoxStore(await openStore());
  }

  void close() => store.close();
}
