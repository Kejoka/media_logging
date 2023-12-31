import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/domain/use_cases/get_all_media.dart';

/// MediaContantBuilder returns a FutureBuilder that fetches data
/// for a given media type and year. The data will then be shown in a ListView
/// by the ListViewBuilder Widget

class MediaContentBuilder extends StatelessWidget {
  const MediaContentBuilder(
      {required this.builder,
      required this.filterYear,
      required this.mediaIndex,
      required this.appMode,
      super.key});

  final dynamic builder;
  final int filterYear;
  final int mediaIndex;
  final String appMode;
  final List<String> mediaTypes = const ["games", "movies", "shows", "books"];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance
          .get<GetAllMedia>()
          .call(filterYear, mediaTypes[mediaIndex], appMode),
      builder: ((context, snapshot) {
        // Decided not to show a Loading Icon since switching from showing
        // this to actual content was very fast anyway and it just caused all
        // items to flash on every refresh, which I found to be very annoying
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

        if (snapshot.hasData) {
          return builder(media);
        }
        return Container();
      }),
    );
  }
}
