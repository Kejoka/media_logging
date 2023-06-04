import 'package:media_logging/domain/repositories/database_repository.dart';

class EmptyDatabase {
  final DatabaseRepository _databaseRepository;

  EmptyDatabase(this._databaseRepository);

  Future<void> call() {
    return _databaseRepository.emptyDatabase();
  }
}
