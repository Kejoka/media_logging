class DBBookModel {
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
  final int backlogged;

  DBBookModel({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.author,
    required this.rating,
    required this.averageRating,
    required this.pageCount,
    required this.release,
    required this.addedIn,
    required this.backlogged,
    this.id = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "subtitle": subtitle,
      "image": image,
      "author": author,
      "rating": rating,
      "averageRating": averageRating,
      "pageCount": pageCount,
      "release": release.toString(),
      "addedIn": addedIn,
      "backlogged": backlogged,
    };
  }

  DBBookModel.fromMap(Map<String, dynamic> item)
      : title = item["title"],
        subtitle = item["subtitle"],
        image = item["image"],
        author = item["author"],
        rating = item["rating"],
        averageRating = item["averageRating"],
        pageCount = item["pageCount"],
        release = DateTime.tryParse(item["release"]),
        addedIn = item["addedIn"],
        id = item["id"],
        backlogged = item["backlogged"];
}
