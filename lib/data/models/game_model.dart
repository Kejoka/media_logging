class GameModel {
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
  final int backlogged;

  GameModel(
      {this.id = 0,
      required this.title,
      required this.image,
      required this.release,
      required this.genres,
      required this.platforms,
      required this.averageRating,
      required this.rating,
      required this.addedIn,
      required this.trophy,
      required this.backlogged});

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "image": image,
      "release": release.toString(),
      "genres": genres.fold("", (previousValue, element) {
        if (element.isNotEmpty) {
          return previousValue += "$element,";
        } else {
          return previousValue;
        }
      }),
      "platforms": platforms.fold("", (previousValue, element) {
        if (element.isNotEmpty) {
          return previousValue += "$element,";
        } else {
          return previousValue;
        }
      }),
      "averageRating": averageRating,
      "rating": rating,
      "addedIn": addedIn,
      "trophy": trophy,
      "backlogged": backlogged
    };
  }

  GameModel.fromMap(Map<String, dynamic> item)
      : id = item["id"],
        title = item["title"],
        image = item["image"],
        release = DateTime.tryParse(item["release"]),
        genres = item["genres"].split(','),
        platforms = item["platforms"].split(','),
        averageRating = item["averageRating"],
        rating = item["rating"],
        addedIn = item["addedIn"],
        trophy = item["trophy"],
        backlogged = item["backlogged"];
}
