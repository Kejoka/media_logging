abstract class DatabaseRepository {
  Future<List<Object?>> getYearList(int? mediaIndex);
  Future<void> emptyDatabase();
  Future<bool> exportDatabase();
  Future<bool> importDatabase();
  Future<void> deleteDatabase();
}
