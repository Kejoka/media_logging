import 'package:media_logging/domain/repositories/media_repository.dart';

class GetSuggestions {
  final MediaRepository _mediaRepository;

  GetSuggestions(this._mediaRepository);

  Future<List> call(String queryString, String mediaType, String? appMode,
      {int? addedIn, int? queryYear}) {
    return _mediaRepository.getSuggestions(queryString, mediaType, appMode,
        addedIn: addedIn, queryYear: queryYear);
  }
}
