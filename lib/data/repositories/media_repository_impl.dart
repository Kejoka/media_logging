import 'dart:convert';
import 'dart:developer';
import 'package:books_finder/books_finder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_logging/data/models/db_book_model.dart';
import 'package:media_logging/data/models/game_model.dart';
import 'package:media_logging/data/models/movie_model.dart';
import 'package:media_logging/data/models/show_model.dart';
import 'package:media_logging/domain/entities/db_book.dart';
import 'package:media_logging/domain/entities/game.dart';
import 'package:media_logging/domain/entities/movie.dart';
import 'package:media_logging/domain/entities/show.dart';
import 'package:media_logging/domain/repositories/media_repository.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:tmdb_api/tmdb_api.dart';

/// Repository that manages all database inserts and accesses concerning media
/// entries. Also contains the api access functionality

class MediaRepositoryImpl implements MediaRepository {
  Future<Database> initDB() async {
    String dbPath = await getDatabasesPath();
    return openDatabase(join(dbPath, "media_database.db"), version: 2,
        onCreate: (database, version) async {
      await database.execute(
          "CREATE TABLE games (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, addedIn NUMBER, image TEXT, release TEXT, genres TEXT, platforms TEXT, averageRating REAL, medal NUMBER, trophy NUMBER)");
      await database.execute(
          "CREATE TABLE movies (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, image TEXT, genres TEXT, addedIn NUMBER, release TEXT, medal NUMBER, averageRating REAL)");
      await database.execute(
          "CREATE TABLE shows (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, image TEXT, genres TEXT, addedIn NUMBER, release TEXT, medal NUMBER, seasons TEXT, averageRating REAL)");
      await database.execute(
          "CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, subtitle TEXT, image TEXT, author TEXT, medal NUMBER, averageRating REAL, pageCount NUMBER, release TEXT, addedIn NUMBER)");
    },
    onUpgrade: (database, oldVersion, newVersion) async {
      if (newVersion == 2) {
        await database.execute("ALTER TABLE shows ADD COLUMN episode INT DEFAULT 0");
      }
    });
  }

  @override
  Future<List<Object>> getAll(int filterYear, String mediaType) async {
    final db = await initDB();
    final List<Map<String, Object?>> result = await db.query(mediaType,
        where: "addedIn = $filterYear", orderBy: "id desc");

    switch (mediaType) {
      case "games":
        final dbGames = result.map((e) => GameModel.fromMap(e));
        return dbGames
            .map((e) => Game(e.id, e.title, e.image, e.release, e.genres,
                e.platforms, e.averageRating, e.medal, e.addedIn, e.trophy))
            .toList();
      case "movies":
        final dbMovies = result.map((e) => MovieModel.fromMap(e));
        return dbMovies
            .map((e) => Movie(e.title, e.image, e.genres, e.addedIn, e.release,
                e.medal, e.averageRating, e.id))
            .toList();
      case "shows":
        final dbShows = result.map((e) => ShowModel.fromMap(e));
        return dbShows
            .map((e) => Show(e.title, e.image, e.genres, e.addedIn, e.release,
                e.medal, e.seasonsA, e.seasonsB, e.averageRating, e.episode, e.id))
            .toList();
      case "books":
        final dbBooks = result.map((e) => DBBookModel.fromMap(e));
        return dbBooks
            .map((e) => DbBook(e.title, e.subtitle, e.image, e.author, e.medal,
                e.averageRating, e.pageCount, e.release, e.addedIn, e.id))
            .toList();
      default:
        return [];
    }
  }

  @override
  Future<void> addMedium(dynamic medium) async {
    final Database db = await initDB();
    switch (medium.runtimeType) {
      case GameModel:
        await db.insert("games", medium.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        break;
      case MovieModel:
        await db.insert("movies", medium.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        break;
      case ShowModel:
        await db.insert("shows", medium.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        break;
      case DBBookModel:
        await db.insert("books", medium.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        break;
    }
  }

  @override
  Future<void> updateMedium(dynamic medium) async {
    final db = await initDB();
    switch (medium.runtimeType) {
      case GameModel:
        await db.update('games', medium.toMap(),
            where: 'id = ?', whereArgs: [medium.id]);
        return;
      case MovieModel:
        await db.update('movies', medium.toMap(),
            where: 'id = ?', whereArgs: [medium.id]);
        return;
      case ShowModel:
        await db.update('shows', medium.toMap(),
            where: 'id = ?', whereArgs: [medium.id]);
        return;
      case DBBookModel:
        await db.update('books', medium.toMap(),
            where: 'id = ?', whereArgs: [medium.id]);
        return;
      default:
        return;
    }
  }

  @override
  Future<void> deleteMedium(int id, String medium) async {
    final db = await initDB();
    try {
      await db.delete(medium, where: "id = ?", whereArgs: [id]);
    } catch (error) {
      log(error.toString());
    }
  }

  /// Functions that will fetch suggestions dpending on the given media type
  @override
  Future<List> getSuggestions(String queryString, String mediaType,
      {int? addedIn, int? queryYear}) async {
    if (queryString.isEmpty) {
      return [];
    }
    switch (mediaType) {
      case "games":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await dotenv.load();
        if (dotenv.env['IGDB_CLIENT'] == null) {
          return [];
        }
        // Fetch data from igdb with regular http
        final result = await http.post(
            Uri.parse("https://api.igdb.com/v4/games/"),
            headers: {
              "Client-ID": dotenv.env['IGDB_CLIENT'] ?? "",
              "Authorization": "Bearer ${prefs.getString('igdb')}",
              "Accept": "application/json"
            },
            body:
                "fields name, cover.image_id, first_release_date, genres.name, platforms.abbreviation, total_rating; where (name ~ *\"$queryString\"* & genres != null & platforms != null & cover != null & version_parent = null & first_release_date != null); sort first_release_date desc; limit 25;");

        /// Return empty list in case api authorization fails
        if (result.statusCode == 401) {
          return [];
        }
        final jsonResult = jsonDecode(result.body) as List;
        final games = jsonResult
            .map((element) =>
                gameModelFromJson(element, addedIn ?? DateTime.now().year))
            .map((e) => Game(e.id, e.title, e.image, e.release, e.genres,
                e.platforms, e.averageRating, e.medal, e.addedIn, e.trophy))
            .toList();
        return games;
      case "movies":
        /// Fetch data from tmdb with the tmdb dart wrapper
        await dotenv.load();
        if (dotenv.env['TMDB_V3'] == null || dotenv.env['TMDB_TOKEN_V4'] == null) {
          return [];
        }
        final tmdb = TMDB(
            ApiKeys(dotenv.env['TMDB_V3'] ?? "", dotenv.env['TMDB_TOKEN_V4'] ?? ""),
            defaultLanguage: 'de-DE');
        Map results;
        if (queryYear != null) {
          results =
              await tmdb.v3.search.queryMovies(queryString, year: queryYear);
        } else {
          results = await tmdb.v3.search.queryMovies(queryString);
        }
        List<dynamic> suggestions = [];
        // log(results.toString());
        for (var result in results["results"]) {
          try {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            bool releaseLock = prefs.getBool('release_lock') ?? true;
            if (releaseLock) {
              if (!DateTime.parse(result["release_date"])
                  .isAfter(DateTime.now())) {
                suggestions.add(result);
              }
            }
            else {
              suggestions.add(result);
            }
          } catch (error) {
            log(error.toString());
          }
        }
        return suggestions;
      case "shows":
        /// Fetch data from tmdb with the tmdb dart wrapper
        await dotenv.load();
        if (dotenv.env['TMDB_V3'] == null || dotenv.env['TMDB_TOKEN_V4'] == null) {
          return [];
        }
        final tmdb = TMDB(
            ApiKeys(dotenv.env['TMDB_V3'] ?? "", dotenv.env['TMDB_TOKEN_V4'] ?? ""),
            defaultLanguage: 'de-DE');
        Map results = await tmdb.v3.search.queryTvShows(queryString);
        List<dynamic> suggestions = [];
        for (var result in results["results"]) {
          try {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            bool releaseLock = prefs.getBool('release_lock') ?? true;
            if (releaseLock) {
              if (!DateTime.parse(result["first_air_date"])
                  .isAfter(DateTime.now())) {
                suggestions.add(result);
              }
            }
            else {
              suggestions.add(result);
            }
          } catch (error) {
            log(error.toString());
          }
        }
        return suggestions;
      case "books":
        /// Fetch data from google books with the official dart wrapper
        final List<Book> books = await queryBooks(
          queryString,
          maxResults: 20,
          langRestrict: "de",
          printType: PrintType.books,
          orderBy: OrderBy.relevance,
        );
        List<Book> returnBooks = [];
        for (Book book in books) {
          if (book.info.authors.isNotEmpty) {
            returnBooks.add(book);
          }
        }
        return returnBooks;
      default:
        return [];
    }
  }

  GameModel gameModelFromJson(Map<String, dynamic> json, int addedIn) {
    if (json["cover"] != null && json["cover"]["image_id"] != null) {
      json["cover"] =
          "https://images.igdb.com/igdb/image/upload/t_cover_big/${json["cover"]["image_id"]}.jpg";
    } else {
      json["cover"] = "";
    }
    if (json["genres"] != null) {
      List<String> genreList = [];
      for (var genre in json["genres"]) {
        // Extract abbreviations (RPG instead of Role Playing Game)
        int parOpenIndex = genre["name"].indexOf("(");
        int parCloseIndex = genre["name"].indexOf(")");
        if (parOpenIndex != -1 && parCloseIndex != -1) {
          genreList.add((genre["name"] as String)
              .substring(parOpenIndex + 1, parCloseIndex));
        } else {
          genreList.add(genre["name"]);
        }
      }
      json["genres"] = genreList;
    }
    if (json["platforms"] != null) {
      List<String> platformList = [];
      for (var platform in json["platforms"]) {
        if (platform["abbreviation"] != null) {
          platformList.add(platform["abbreviation"]);
        }
      }
      json["platforms"] = platformList;
    }
    if (json["total_rating"] == null) {
      json["total_rating"] = 0.0;
    }
    if (json["first_release_date"] != null) {
      json["first_release_date"] = DateTime.fromMillisecondsSinceEpoch(
          (json["first_release_date"] as int) * 1000);
    }
    var ratingString = (json["total_rating"] / 10).toStringAsFixed(1);
    json["total_rating"] = double.parse(ratingString);
    var game = GameModel(
        title: utf8.decode(json["name"].runes.toList()),
        image: json["cover"],
        release: json["first_release_date"],
        genres: json["genres"],
        platforms: json["platforms"],
        averageRating: json["total_rating"],
        medal: 0,
        trophy: 0,
        addedIn: addedIn);
    return game;
  }

  @override
  Future<List<String>> getGenres(List genreIds, String mediaType) async {
    final tmdb = TMDB(
        ApiKeys('0ab66def8801edbe3cda8bd0d9026712',
            'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwYWI2NmRlZjg4MDFlZGJlM2NkYThiZDBkOTAyNjcxMiIsInN1YiI6IjYzOWY4ZjNlYmU2ZDg4MDA3ZjE3ZWI3NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.TDGISFMYUf5XzmB2xhIsrcgNhhjmC229jHFo828odD0'),
        defaultLanguage: 'de-DE');
    dynamic genres;
    if (mediaType == "movies") {
      genres = await tmdb.v3.genres.getMovieList();
    } else if (mediaType == "shows") {
      genres = await tmdb.v3.genres.getTvlist();
    }
    List<String> genreList = [];
    for (var genreID in genreIds) {
      for (var object in genres["genres"]) {
        if (object["id"] == genreID) {
          genreList.add(object["name"]);
        }
      }
    }
    if (genreList.length > 3) {
      genreList.length = 3;
    }
    return genreList;
  }

  @override
  Future<String> getTMDBImageURL(String posterPath) async {
    final tmdb = TMDB(
        ApiKeys('0ab66def8801edbe3cda8bd0d9026712',
            'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwYWI2NmRlZjg4MDFlZGJlM2NkYThiZDBkOTAyNjcxMiIsInN1YiI6IjYzOWY4ZjNlYmU2ZDg4MDA3ZjE3ZWI3NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.TDGISFMYUf5XzmB2xhIsrcgNhhjmC229jHFo828odD0'),
        defaultLanguage: 'de-DE');
    return tmdb.images.getUrl(posterPath) ?? "";
  }
}
