import 'package:media_logging/domain/repositories/stat_repository.dart';

class GetMovieStats {
  final StatRepository _statRepository;

  GetMovieStats(this._statRepository);

  Future<List<List<Map<String, dynamic>>>> call(int filterYear) {
    return _statRepository.getMovieStats(filterYear);
  }
}
