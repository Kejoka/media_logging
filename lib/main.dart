import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:media_logging/data/repositories/database_repository_impl.dart';
import 'package:media_logging/data/repositories/media_repository_impl.dart';
import 'package:media_logging/data/repositories/stat_repository_impl.dart';
import 'package:media_logging/domain/repositories/database_repository.dart';
import 'package:media_logging/domain/repositories/media_repository.dart';
import 'package:media_logging/domain/repositories/stat_repository.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/delete_medium.dart';
import 'package:media_logging/domain/use_cases/empty_databse.dart';
import 'package:media_logging/domain/use_cases/export_database.dart';
import 'package:media_logging/domain/use_cases/get_book_stats.dart';
import 'package:media_logging/domain/use_cases/get_game_stats.dart';
import 'package:media_logging/domain/use_cases/get_movie_stats.dart';
import 'package:media_logging/domain/use_cases/get_all_media.dart';
import 'package:media_logging/domain/use_cases/get_genres.dart';
import 'package:media_logging/domain/use_cases/get_show_stats.dart';
import 'package:media_logging/domain/use_cases/get_suggestions.dart';
import 'package:media_logging/domain/use_cases/get_tmdb_image_url.dart';
import 'package:media_logging/domain/use_cases/get_year_list.dart';
import 'package:media_logging/domain/use_cases/import_database.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';
import 'package:media_logging/presentation/media_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  GetIt.instance.registerSingleton<MediaRepository>(MediaRepositoryImpl());
  GetIt.instance
      .registerSingleton<DatabaseRepository>(DatabaseRepositoryImpl());
  GetIt.instance.registerSingleton<StatRepository>(StatRepositoryImpl());
  GetIt.instance.registerFactory(
      () => GetAllMedia(GetIt.instance.get<MediaRepository>()));
  GetIt.instance.registerFactory(
      () => CreateMedium(GetIt.instance.get<MediaRepository>()));
  GetIt.instance.registerFactory(
      () => UpdateMedium(GetIt.instance.get<MediaRepository>()));
  GetIt.instance.registerFactory(
      () => DeleteMedium(GetIt.instance.get<MediaRepository>()));
  GetIt.instance.registerFactory(
      () => GetSuggestions(GetIt.instance.get<MediaRepository>()));
  GetIt.instance
      .registerFactory(() => GetGenres(GetIt.instance.get<MediaRepository>()));
  GetIt.instance.registerFactory(
      () => GetTMDBImageURL(GetIt.instance.get<MediaRepository>()));
  GetIt.instance.registerFactory(
      (() => EmptyDatabase(GetIt.instance.get<DatabaseRepository>())));
  GetIt.instance.registerFactory(
      (() => ExportDatabase(GetIt.instance.get<DatabaseRepository>())));
  GetIt.instance.registerFactory(
      (() => ImportDatabase(GetIt.instance.get<DatabaseRepository>())));
  GetIt.instance.registerFactory(
      (() => GetYearList(GetIt.instance.get<DatabaseRepository>())));
  GetIt.instance.registerFactory(
      () => GetMovieStats(GetIt.instance.get<StatRepository>()));
  GetIt.instance.registerFactory(
      () => GetGameStats(GetIt.instance.get<StatRepository>()));
  GetIt.instance.registerFactory(
      () => GetShowStats(GetIt.instance.get<StatRepository>()));
  GetIt.instance.registerFactory(
      () => GetBookStats(GetIt.instance.get<StatRepository>()));
  await dotenv.load();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Make sure the IGDB Key is still valid
  if (prefs.getString('igdb') == null &&
      dotenv.env['IGDB_CLIENT'] != null &&
      dotenv.env['IGDB_SECRET'] != null) {
    final result = await http.post(Uri.parse(
        "https://id.twitch.tv/oauth2/token?client_id=${dotenv.env['IGDB_CLIENT']}&client_secret=${dotenv.env['IGDB_SECRET']}&grant_type=client_credentials"));
    final jsonRes = jsonDecode(result.body);
    String igdbKey = jsonRes['access_token'].toString();
    prefs.setString('igdb', igdbKey);
  } else {
    if (dotenv.env['IGDB_CLIENT'] != null &&
        dotenv.env['IGDB_SECRET'] != null) {
      final result = await http.post(
        Uri.parse("https://api.igdb.com/v4/games/"),
        headers: {
          "Client-ID": dotenv.env['IGDB_CLIENT'] ?? "",
          "Authorization": "Bearer ${prefs.getString('igdb')}",
          "Accept": "application/json"
        },
      );
      log(result.statusCode.toString());

      /// Return empty list in case api authorization fails
      if (result.statusCode == 401) {
        final result = await http.post(Uri.parse(
            "https://id.twitch.tv/oauth2/token?client_id=${dotenv.env['IGDB_CLIENT']}&client_secret=${dotenv.env['IGDB_SECRET']}&grant_type=client_credentials"));
        final jsonRes = jsonDecode(result.body);
        String igdbKey = jsonRes['access_token'].toString();
        prefs.setString('igdb', igdbKey);

        final resultB = await http.post(
          Uri.parse("https://api.igdb.com/v4/games/"),
          headers: {
            "Client-ID": dotenv.env['IGDB_CLIENT'] ?? "",
            "Authorization": "Bearer ${prefs.getString('igdb')}",
            "Accept": "application/json"
          },
        );
        log(resultB.statusCode.toString());
      }
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medien-Regal',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MediaNavigator(),
    );
  }
}
