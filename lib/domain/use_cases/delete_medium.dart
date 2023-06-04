import 'package:media_logging/domain/repositories/media_repository.dart';

class DeleteMedium {
  final MediaRepository _mediaRepository;

  DeleteMedium(this._mediaRepository);

  Future<void> call(int id, String medium) {
    return _mediaRepository.deleteMedium(id, medium);
  }
}
