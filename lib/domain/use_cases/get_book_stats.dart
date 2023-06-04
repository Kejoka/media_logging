import 'package:media_logging/domain/repositories/stat_repository.dart';

class GetBookStats {
  final StatRepository _statRepository;

  GetBookStats(this._statRepository);

  Future<List<List<Map<String, dynamic>>>> call(int filterYear) {
    return _statRepository.getBookStats(filterYear);
  }
}
