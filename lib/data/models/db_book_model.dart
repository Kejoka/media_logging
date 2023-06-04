class DBBookModel {
  final String title;
  final String subtitle;
  final String image;
  final String author;
  int medal;
  final double averageRating;
  final int pageCount;
  final DateTime? release;
  final int addedIn;
  final int id;

  DBBookModel({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.author,
    required this.medal,
    required this.averageRating,
    required this.pageCount,
    required this.release,
    required this.addedIn,
    this.id = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "subtitle": subtitle,
      "image": image,
      "author": author,
      "medal": medal,
      "averageRating": averageRating,
      "pageCount": pageCount,
      "release": release.toString(),
      "addedIn": addedIn,
    };
  }

  DBBookModel.fromMap(Map<String, dynamic> item)
      : title = item["title"],
        subtitle = item["subtitle"],
        image = item["image"],
        author = item["author"],
        medal = item["medal"],
        averageRating = item["averageRating"],
        pageCount = item["pageCount"],
        release = DateTime.tryParse(item["release"]),
        addedIn = item["addedIn"],
        id = item["id"];
}
