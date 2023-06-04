import 'package:media_logging/domain/repositories/media_repository.dart';

class UpdateMedium {
  final MediaRepository _mediaRepository;

  UpdateMedium(this._mediaRepository);

  Future<void> call(dynamic medium) {
    return _mediaRepository.updateMedium(medium);
  }
}
