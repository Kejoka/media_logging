import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/db_book_model.dart';
import 'package:media_logging/data/models/game_model.dart';
import 'package:media_logging/data/models/movie_model.dart';
import 'package:media_logging/data/models/show_model.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/delete_medium.dart';
import 'package:media_logging/presentation/forms/book_manual_form.dart';
import 'package:media_logging/presentation/forms/game_manual_form.dart';
import 'package:media_logging/presentation/forms/movie_manual_form.dart';
import 'package:media_logging/presentation/forms/show_manual_form.dart';
import 'package:media_logging/presentation/media_content_builder.dart';
import 'package:media_logging/presentation/items/book_item.dart';
import 'package:media_logging/presentation/items/game_item.dart';
import 'package:media_logging/presentation/items/movie_item.dart';
import 'package:media_logging/presentation/items/show_item.dart';
import 'package:media_logging/presentation/items/stat_item.dart';
import 'package:media_logging/presentation/stats_content_builder.dart';

/// ListViewBuilder that builds the ListView depending on the given mediaIndex and

class ListViewBuilder extends StatefulWidget {
  const ListViewBuilder(
      {required this.filterYear,
      required this.mediaIndex,
      required this.appMode,
      super.key});
  final int filterYear;
  final int mediaIndex;
  final String appMode;
  @override
  State<ListViewBuilder> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<ListViewBuilder> {
  @override
  Widget build(BuildContext context) {
    // MediaView
    log(widget.appMode);
    if (widget.appMode != "Statistiken") {
      return MediaContentBuilder(
        mediaIndex: widget.mediaIndex,
        filterYear: widget.filterYear,
        appMode: widget.appMode,
        builder: (media) => ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: media.length,
          itemBuilder: (context, index) {
            final medium = media[index];
            switch (widget.mediaIndex) {
              // List of games
              case 0:
                return GameItem(
                  game: medium,
                  appMode: widget.appMode,
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          longPress(medium, "games")),
                  onTap: () async {
                    log(medium.id.toString());
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => GameManualForm(
                              game: medium,
                            )));
                    setState(() {});
                  },
                );
              // List of movies
              case 1:
                return MovieItem(
                  movie: medium,
                  appMode: widget.appMode,
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          longPress(medium, "movies")),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MovieManualForm(
                              movie: medium,
                            )));
                    setState(() {});
                  },
                );
              // List of shows
              case 2:
                return ShowItem(
                  show: medium,
                  appMode: widget.appMode,
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          longPress(medium, "shows")),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ShowManualForm(
                              show: medium,
                            )));
                    setState(() {});
                  },
                );
              // List of books
              case 3:
                return BookItem(
                  book: medium,
                  appMode: widget.appMode,
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          longPress(medium, "books")),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BookManualForm(
                              book: medium,
                            )));
                    setState(() {});
                  },
                );
              // Default so flutter won't complain
              default:
                return Container();
            }
          },
        ),
      );
    }
    // StatView
    else {
      // List of movie stats
      return StatsContentBuilder(
          builder: (statistics) => ListView.builder(
              itemCount: statistics.length,
              itemBuilder: (context, index) {
                final stat = statistics[index];
                return StatItem(
                  statValues: stat,
                );
              }),
          filterYear: widget.filterYear,
          mediaIndex: widget.mediaIndex);
    }
  }

  /// Extracted onlongPress to to a function
  longPress(dynamic medium, String mediaType) {
    log(medium.addedIn.toString());
    if (widget.appMode == "Medien-Regal") {
      return CupertinoAlertDialog(
        title: Text("${medium.title} löschen?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Abbrechen"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text("Löschen"),
            onPressed: () {
              GetIt.instance.get<DeleteMedium>().call(medium.id, mediaType);
              setState(() {});
              Navigator.of(context).pop();
            },
          )
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text("${medium.title} aus dem Backlog verschieben?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Abbrechen"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text("Verschieben"),
            onPressed: () {
              setState(() {
                medium.backlogged = 2;
              });
              switch (widget.mediaIndex) {
                case 0:
                  GetIt.instance.get<CreateMedium>().call(GameModel(
                      title: medium.title,
                      image: medium.image,
                      release: medium.release,
                      genres: medium.genres,
                      platforms: medium.platforms,
                      averageRating: medium.averageRating,
                      rating: medium.rating,
                      addedIn: DateTime.now().year,
                      trophy: medium.trophy,
                      backlogged: medium.backlogged));
                  GetIt.instance.get<DeleteMedium>().call(medium.id, 'games');
                  break;
                case 1:
                  GetIt.instance.get<CreateMedium>().call(MovieModel(
                      title: medium.title,
                      image: medium.image,
                      genres: medium.genres,
                      addedIn: DateTime.now().year,
                      release: medium.release,
                      rating: medium.rating,
                      averageRating: medium.averageRating,
                      backlogged: medium.backlogged));
                  GetIt.instance.get<DeleteMedium>().call(medium.id, 'movies');
                  break;
                case 2:
                  GetIt.instance.get<CreateMedium>().call(ShowModel(
                      title: medium.title,
                      image: medium.image,
                      genres: medium.genres,
                      addedIn: DateTime.now().year,
                      release: medium.release,
                      rating: medium.rating,
                      seasonsA: medium.seasonsA,
                      seasonsB: medium.seasonsB,
                      averageRating: medium.averageRating,
                      episode: medium.episode,
                      backlogged: medium.backlogged));
                  GetIt.instance.get<DeleteMedium>().call(medium.id, 'shows');
                  break;
                case 3:
                  GetIt.instance.get<CreateMedium>().call(DBBookModel(
                      title: medium.title,
                      subtitle: medium.subtitle,
                      image: medium.image,
                      author: medium.author,
                      rating: medium.rating,
                      averageRating: medium.averageRating,
                      pageCount: medium.pageCount,
                      release: medium.release,
                      addedIn: DateTime.now().year,
                      backlogged: medium.backlogged));
                  GetIt.instance.get<DeleteMedium>().call(medium.id, 'books');
                  break;
              }
              // setState(() {});
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }
  }
}
