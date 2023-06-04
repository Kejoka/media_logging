import 'package:media_logging/domain/repositories/media_repository.dart';

class GetAllMedia {
  final MediaRepository _mediaRepository;

  GetAllMedia(this._mediaRepository);

  Future<List> call(int filterYear, String mediaType) {
    return _mediaRepository.getAll(filterYear, mediaType);
  }
}
