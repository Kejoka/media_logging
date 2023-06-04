import 'package:media_logging/domain/repositories/database_repository.dart';

class ExportDatabase {
  final DatabaseRepository _databaseRepository;

  ExportDatabase(this._databaseRepository);

  Future<bool> call() {
    return _databaseRepository.exportDatabase();
  }
}
