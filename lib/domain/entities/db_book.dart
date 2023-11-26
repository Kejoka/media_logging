// This class is called DbBook and not just Book since the google books dart wrapper
// already uses a class called Book

class DbBook {
  final String title;
  final String subtitle;
  final String image;
  final String author;
  double rating;
  final double averageRating;
  final int pageCount;
  final DateTime? release;
  final int addedIn;
  final int id;

  DbBook(this.title, this.subtitle, this.image, this.author, this.rating,
      this.averageRating, this.pageCount, this.release, this.addedIn, this.id);

  // This function generates the string that will be displayed in the Book Tile
  String getTileText() {
    String returnString = "";
    if (author.isNotEmpty) {
      returnString += author;
    }
    if (pageCount != 0) {
      returnString += "\nSeiten: $pageCount";
    }
    if (averageRating != 0) {
      returnString += "\nDurchschnittliche Bewertung: $averageRating";
    }
    if (release != null) {
      returnString +=
          "\nErschienen: ${release?.day}.${release?.month}.${release?.year}";
    }
    return returnString;
  }
}
