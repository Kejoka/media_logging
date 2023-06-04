import 'package:media_logging/domain/repositories/media_repository.dart';

class GetGenres {
  final MediaRepository _mediaRepository;

  GetGenres(this._mediaRepository);

  Future<List<String>> call(List<dynamic> genreIds, String mediaType) {
    return _mediaRepository.getGenres(genreIds, mediaType);
  }
}
