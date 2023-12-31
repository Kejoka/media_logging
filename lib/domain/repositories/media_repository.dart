abstract class MediaRepository {
  Future<List> getAll(int filterYear, String mediaType, String appMode);
  Future<void> addMedium(dynamic medium);
  Future<void> updateMedium(dynamic medium);
  Future<void> deleteMedium(int id, String medium);
  Future<List> getSuggestions(
      String queryString, String mediaType, String? appMode,
      {int? addedIn, int? queryYear});
  Future<List<String>> getGenres(List<dynamic> genreIds, String mediaType);
  Future<String> getTMDBImageURL(String posterPath);
}
