class Show {
  final String title;
  final String image;
  final List<String> genres;
  final int addedIn;
  final DateTime? release;
  int medal;
  final int seasonsA;
  final int seasonsB;
  final int id;
  final double averageRating;
  int episode;

  Show(this.title, this.image, this.genres, this.addedIn, this.release,
      this.medal, this.seasonsA, this.seasonsB, this.averageRating, this.episode, this.id);
      
  // This function generates the string that will be displayed in the Show Tile
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
    }
    if (seasonsA != 0 && seasonsB != 0 && seasonsB >= seasonsA) {
      if (seasonsA == seasonsB) {
        returnString += "\nStaffel $seasonsA";
      } else {
        returnString += "\nStaffel $seasonsA-$seasonsB";
      }
    }
    if (release != null) {
      returnString +=
          "\nPremiere: ${release?.day}.${release?.month}.${release?.year}";
    }
    if (averageRating != 0.0) {
      returnString += "\nDurchschnittliche Bewertung: $averageRating";
    }
    return returnString;
  }
}
