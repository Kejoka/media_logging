class Movie {
  final String title;
  final String image;
  final List<String> genres;
  final int addedIn;
  final DateTime? release;
  int medal;
  final int id;
  final double averageRating;

  Movie(this.title, this.image, this.genres, this.addedIn, this.release,
      this.medal, this.averageRating, this.id);
      
  // This function generates the string that will be displayed in the Movie Tile
  String getTileText() {
    String returnString = "";
    int genreCount = 0;
    int genreLimit = 3;
    for (var element in genres) {
      if (element.isNotEmpty && genreCount < genreLimit) {
        returnString += "$element, ";
        genreCount += 1;
      }
    }
    if (returnString.length >= 2) {
      returnString = returnString.substring(0, returnString.length - 2);
      if (release != null) {
        returnString +=
            "\nErschienen: ${release?.day}.${release?.month}.${release?.year}";
      }
    } else if (release != null) {
      returnString += "${release?.day}.${release?.month}.${release?.year}";
    }
    if (averageRating != 0) {
      returnString += "\nDurchschnittliche Bewertung: $averageRating";
    }
    return returnString;
  }
}
