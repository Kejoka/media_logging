import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
    if (widget.appMode == "Medien-Regal") {
      return MediaContentBuilder(
        mediaIndex: widget.mediaIndex,
        filterYear: widget.filterYear,
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
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          deleteItem(medium.title, medium.id, "games")),
                  onTap: () async {
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
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          deleteItem(medium.title, medium.id, "movies")),
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
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          deleteItem(medium.title, medium.id, "shows")),
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
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          deleteItem(medium.title, medium.id, "books")),
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

  /// Extracted onlongPressto to a function
  deleteItem(String title, int id, String mediaType) {
    return CupertinoAlertDialog(
      title: Text("$title löschen?"),
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
            GetIt.instance.get<DeleteMedium>().call(id, mediaType);
            setState(() {});
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
