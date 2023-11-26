class MovieModel {
  final String title;
  final String image;
  final List<String> genres;
  final int addedIn;
  final DateTime? release;
  double rating;
  final int id;
  final double averageRating;

  MovieModel({
    required this.title,
    required this.image,
    required this.genres,
    required this.addedIn,
    required this.release,
    required this.rating,
    required this.averageRating,
    this.id = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "image": image,
      "genres": genres.fold("", (previousValue, element) {
        if (element.isNotEmpty) {
          return previousValue += "$element,";
        } else {
          return previousValue;
        }
      }),
      "addedIn": addedIn,
      "release": release.toString(),
      "rating": rating,
      "averageRating": averageRating,
    };
  }

  MovieModel.fromMap(Map<String, dynamic> item)
      : title = item["title"],
        image = item["image"],
        genres = item["genres"].split(','),
        addedIn = item["addedIn"],
        release = DateTime.tryParse(item["release"]),
        rating = item["rating"],
        id = item["id"],
        averageRating = item["averageRating"];
}
