import 'package:media_logging/domain/repositories/database_repository.dart';

class GetYearList {
  final DatabaseRepository _databaseRepository;

  GetYearList(this._databaseRepository);

  Future<List<Object?>> call(int? mediaIndex) {
    return _databaseRepository.getYearList(mediaIndex);
  }
}
