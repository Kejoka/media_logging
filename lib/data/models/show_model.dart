class ShowModel {
  final String title;
  final String image;
  final List<String> genres;
  final int addedIn;
  final DateTime? release;
  final double rating;
  final int seasonsA;
  final int seasonsB;
  final int id;
  final double averageRating;
  final int episode;

  ShowModel({
    required this.title,
    required this.image,
    required this.genres,
    required this.addedIn,
    required this.release,
    required this.rating,
    required this.seasonsA,
    required this.seasonsB,
    required this.averageRating,
    required this.episode,
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
      "seasons":
          (seasonsA == seasonsB) ? seasonsA.toString() : "$seasonsA-$seasonsB",
      "averageRating": averageRating,
      "episode": episode
    };
  }

  ShowModel.fromMap(Map<String, dynamic> item)
      : title = item["title"],
        image = item["image"],
        genres = item["genres"].split(','),
        addedIn = item["addedIn"],
        release = DateTime.tryParse(item["release"]),
        rating = item["rating"],
        seasonsA = (item["seasons"].contains('-'))
            ? int.parse(item["seasons"].substring(0, item["seasons"].indexOf('-')))
            : int.parse(item["seasons"]),
        seasonsB = (item["seasons"].contains('-'))
            ? int.parse(item["seasons"].substring(item["seasons"].indexOf('-')+1, item["seasons"].length))
            : int.parse(item["seasons"]),
        id = item["id"],
        averageRating = item["averageRating"],
        episode = item["episode"] ?? 0;
}
