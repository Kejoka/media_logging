import 'package:media_logging/domain/repositories/media_repository.dart';

class GetSuggestions {
  final MediaRepository _mediaRepository;

  GetSuggestions(this._mediaRepository);

  Future<List> call(String queryString, String mediaType,
      {int? addedIn, int? queryYear}) {
    return _mediaRepository.getSuggestions(queryString, mediaType,
        addedIn: addedIn, queryYear: queryYear);
  }
}
