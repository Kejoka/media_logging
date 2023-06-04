import 'package:media_logging/domain/repositories/media_repository.dart';

class GetTMDBImageURL {
  final MediaRepository _mediaRepository;

  GetTMDBImageURL(this._mediaRepository);

  Future<String> call(String posterPath) {
    return _mediaRepository.getTMDBImageURL(posterPath);
  }
}
