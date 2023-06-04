import 'package:media_logging/domain/repositories/stat_repository.dart';

class GetShowStats {
  final StatRepository _statRepository;

  GetShowStats(this._statRepository);

  Future<List<List<Map<String, dynamic>>>> call(int filterYear) {
    return _statRepository.getShowStats(filterYear);
  }
}
