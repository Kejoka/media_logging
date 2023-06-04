import 'package:media_logging/domain/repositories/database_repository.dart';

class ImportDatabase {
  final DatabaseRepository _databaseRepository;

  ImportDatabase(this._databaseRepository);

  Future<bool> call() {
    return _databaseRepository.importDatabase();
  }
}
