class Game {
  final int id;
  final String title;
  String image;
  final DateTime? release;
  final List<String> genres;
  final List<String> platforms;
  final double averageRating;
  double rating;
  int trophy;
  final int addedIn;

  Game(
    this.id,
    this.title,
    this.image,
    this.release,
    this.genres,
    this.platforms,
    this.averageRating,
    this.rating,
    this.addedIn,
    this.trophy,
  );

  // This function generates the string that will be displayed in the Game Tile
  String getTileText() {
    String tileText = "";
    int genreCount = 0;
    int platformCount = 0;
    int genreLimit = 3;
    for (var element in genres) {
      if (element.isNotEmpty && genreCount < genreLimit) {
        if (genreCount == genreLimit - 1 || genreCount == genres.length - 2) {
          tileText += "$element\n";
          genreCount += 1;
        } else {
          tileText += "$element, ";
          genreCount += 1;
        }
      }
    }
    for (var element in platforms) {
      if (element.isNotEmpty) {
        if (platformCount == platforms.length - 2) {
          tileText += "$element\n";
          platformCount += 1;
        } else {
          tileText += "$element, ";
          platformCount += 1;
        }
      }
    }
    if (release != null) {
      tileText +=
          "Erschienen: ${release?.day}.${release?.month}.${release?.year}\n";
    }
    if (averageRating != 0.0) {
      tileText += "Durchschnittliche Bewertung: $averageRating";
    }
    return tileText;
  }
}
