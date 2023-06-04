import 'package:media_logging/domain/repositories/media_repository.dart';

class CreateMedium {
  final MediaRepository _mediaRepository;

  CreateMedium(this._mediaRepository);

  Future<void> call(dynamic medium) {
    return _mediaRepository.addMedium(medium);
  }
}
