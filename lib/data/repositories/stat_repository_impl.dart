import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:media_logging/domain/repositories/stat_repository.dart';
import 'package:media_logging/domain/use_cases/get_all_media.dart';

/// Repository that is responsible for fetching and preparing all the data needed to generate
/// the graphs for each media type statistsics

class StatRepositoryImpl implements StatRepository {
  @override
  /// Different stat fetch functions for each media type since they all have different
  /// properties and some stats can not be generated for some media types
  Future<List<List<Map<String, dynamic>>>> getGameStats(int filterYear) async {
    List<List<Map<String, dynamic>>> stats = [];
    var games =
        await GetIt.instance.get<GetAllMedia>().call(filterYear, "games", "Medien-Regal");
    if (games.isEmpty) {
      return stats;
    }
    stats.add(await getAddedinStats(games));
    try {
      stats.add(await getRatingStats(games));
    } catch (e) {
      log(e.toString());
    }
    stats.add(await getGenreSpreadStats(games));
    return stats;
  }

  @override
  Future<List<List<Map<String, dynamic>>>> getBookStats(int filterYear) async {
    List<List<Map<String, dynamic>>> stats = [];
    var books =
        await GetIt.instance.get<GetAllMedia>().call(filterYear, "books", "Medien-Regal");
    if (books.isEmpty) {
      return stats;
    }
    stats.add(await getAddedinStats(books));
    try {
      stats.add(await getRatingStats(books));
    } catch (e) {
      log(e.toString());
    }
    return stats;
  }

  @override
  Future<List<List<Map<String, dynamic>>>> getShowStats(int filterYear) async {
    List<List<Map<String, dynamic>>> stats = [];
    var shows =
        await GetIt.instance.get<GetAllMedia>().call(filterYear, "shows", "Medien-Regal");
    if (shows.isEmpty) {
      return stats;
    }
    stats.add(await getAddedinStats(shows));
    try {
      stats.add(await getRatingStats(shows));
    } catch (e) {
      log(e.toString());
    }
    stats.add(await getGenreSpreadStats(shows));
    return stats;
  }

  @override
  Future<List<List<Map<String, dynamic>>>> getMovieStats(int filterYear) async {
    List<List<Map<String, dynamic>>> stats = [];
    var movies =
        await GetIt.instance.get<GetAllMedia>().call(filterYear, "movies", "Medien-Regal");
    if (movies.isEmpty) {
      return stats;
    }
    stats.add(await getAddedinStats(movies));
    try {
      stats.add(await getRatingStats(movies));
    } catch (e) {
      log(e.toString());
    }
    stats.add(await getGenreSpreadStats(movies));
    return stats;
  }
  
  Map<String, dynamic> buildMapFromLists(List<String> a, List b) {
    if (a.length != b.length) {
      return {};
    }
    Map<String, dynamic> returnMap = <String, dynamic>{};
    for (int i = 0; i < a.length; i++) {
      returnMap[a[i]] = b[i];
    }
    return returnMap;
  }

  getAddedinStats(List<dynamic> media) async {
    var matchCount = 0;
    List<Map<String, dynamic>> data = [];
    for (var medium in media) {
      if (medium.addedIn == medium.release?.year) {
        matchCount++;
      }
    }
    var statValues = buildMapFromLists(
        ["matchValue", "totalCount"], [matchCount, media.length]);
    var metadataObject = {
      "chartType": "pie",
      "chartTitle": "Einträge, die im Erscheinungsjahr hinzugefügt wurden"
    };
    Map<String, dynamic> dataObjectA = <String, dynamic>{};
    dataObjectA["label"] = "Dieses Jahr";
    dataObjectA["value"] =
        (statValues["matchValue"] / statValues["totalCount"]) * 100;
    Map<String, dynamic> dataObjectB = <String, dynamic>{};
    dataObjectB["label"] = "Vorher";
    dataObjectB["value"] =
        100 - ((statValues["matchValue"] / statValues["totalCount"]) * 100);
    data.add(metadataObject);
    data.add(dataObjectA);
    data.add(dataObjectB);
    return data;
  }

  getRatingStats(List<dynamic> media) async {
    List<Map<String, dynamic>> data = [];
    double ratingSum = 0;
    int ratingCount = 0;
    List<String> ratingRanges = [
      "0-1",
      "1-2",
      "2-3",
      "3-4",
      "4-5",
      "5-6",
      "6-7",
      "7-8",
      "8-9",
      "9-10"
    ];
    List<int> ratingCounts = List.filled(ratingRanges.length, 0);
    for (var medium in media) {
      ratingSum += medium.averageRating;
      if (medium.averageRating != 0) {
        ratingCount++;
      }
      for (int i = 0; i < ratingRanges.length; i++) {
        var rangeSplit = ratingRanges[i].split("-");
        if (int.parse(rangeSplit[0]) <= medium.averageRating &&
            medium.averageRating < int.parse(rangeSplit[1])) {
          ratingCounts[i]++;
        }
      }
    }
    if (ratingCount == 0) {
      return null;
    }
    data.add({
      "chartType": "bar",
      "chartTitle":
          "Durchschnittliche Bewertung: ${(ratingSum / ratingCount).toStringAsFixed(1)}"
    });
    buildMapFromLists(ratingRanges, ratingCounts).forEach((key, value) {
      Map<String, dynamic> dataObject = <String, dynamic>{};
      dataObject["label"] = key;
      dataObject["value"] = value;
      data.add(dataObject);
    });
    return data;
  }

  getGenreSpreadStats(List<dynamic> media) async {
    List<Map<String, dynamic>> data = [];
    List<String> genres = [];
    List<int> genreCounts = [];
    int genreOcurrenceTotal = 0;
    data.add({"chartType": "pie", "chartTitle": "Genreverteilung"});
    for (var medium in media) {
      for (var genre in medium.genres) {
        if (!genres.contains(genre)) {
          genres.add(genre);
          genreCounts.add(1);
        } else {
          genreCounts[genres.indexOf(genre)]++;
        }
      }
    }

    buildMapFromLists(genres, genreCounts).forEach((key, value) {
      if (key.isNotEmpty) {
        genreOcurrenceTotal += value as int;
      }
    });
    buildMapFromLists(genres, genreCounts).forEach((key, value) {
      if (key.isNotEmpty) {
        Map<String, dynamic> dataObject = <String, dynamic>{};
        dataObject["label"] = key;
        dataObject["value"] = (value / genreOcurrenceTotal) * 100;
        data.add(dataObject);
      }
    });
    return data;
  }
}
