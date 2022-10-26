abstract class IDatabaseProvider {
  Future<void> create(Map<String, dynamic> data);

  Stream read();

  Future<void> update(Map<String, dynamic> data);

  Future<void> delete(Map<String, dynamic> data);
}
