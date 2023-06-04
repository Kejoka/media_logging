abstract class StatRepository {
  Future<List<List<Map<String, dynamic>>>> getGameStats(int filterYear);
  Future<List<List<Map<String, dynamic>>>> getMovieStats(int filterYear);
  Future<List<List<Map<String, dynamic>>>> getShowStats(int filterYear);
  Future<List<List<Map<String, dynamic>>>> getBookStats(int filterYear);
}
