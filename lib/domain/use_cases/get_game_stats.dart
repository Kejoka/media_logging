import 'package:media_logging/domain/repositories/stat_repository.dart';

class GetGameStats {
  final StatRepository _statRepository;

  GetGameStats(this._statRepository);

  Future<List<List<Map<String, dynamic>>>> call(int filterYear) {
    return _statRepository.getGameStats(filterYear);
  }
}
