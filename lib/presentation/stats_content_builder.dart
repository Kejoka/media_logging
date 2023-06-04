import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/domain/use_cases/get_book_stats.dart';
import 'package:media_logging/domain/use_cases/get_game_stats.dart';
import 'package:media_logging/domain/use_cases/get_movie_stats.dart';
import 'package:media_logging/domain/use_cases/get_show_stats.dart';

/// StatsContentBuilder handles alle the possible Statistics that can be
/// generated from the properties of each media type

class StatsContentBuilder extends StatelessWidget {
  const StatsContentBuilder(
      {required this.builder,
      required this.filterYear,
      required this.mediaIndex,
      super.key});

  final dynamic builder;
  final int filterYear;
  final int mediaIndex;
  final List<String> mediaTypes = const ["games", "movies", "shows", "books"];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Pretty long statement but extracting everything to a function did not work
        future: (mediaIndex == 0)
            ? GetIt.instance.get<GetGameStats>().call(filterYear)
            : (mediaIndex == 1)
                ? GetIt.instance.get<GetMovieStats>().call(filterYear)
                : (mediaIndex == 2)
                    ? GetIt.instance.get<GetShowStats>().call(filterYear)
                    : GetIt.instance.get<GetBookStats>().call(filterYear),
        builder: ((context, snapshot) {
          // Decided to not show a Loading Icon since switching from showing
          // this to actual content was very fast anyway and it just caused all
          // items to flash on every refresh
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: CircularProgressIndicator(),
          //   );
          // }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final media = snapshot.data ?? [];
          if (snapshot.hasData && media.isNotEmpty) {
            return builder(snapshot.data);
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Text("Keine Daten gefunden")],
            );
          }
        }));
  }
}
