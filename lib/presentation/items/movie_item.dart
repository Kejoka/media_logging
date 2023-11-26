import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/movie_model.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';
import 'package:media_logging/presentation/custom_gf_list_tile.dart';
import 'package:media_logging/domain/entities/movie.dart';

/// Tile that shows information about a movie. Uses the modified GF List Tile

class MovieItem extends StatefulWidget {
  final Movie movie;
  final Function()? onTap;
  final Function()? onLongPress;

  const MovieItem({
    required this.movie,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  State<MovieItem> createState() => _MovieItemState();
}

class _MovieItemState extends State<MovieItem> {
  final rankImageSelection = [
    'assets/images/blank.png',
    'assets/images/gold.png',
    'assets/images/silver.png',
    'assets/images/bronze.png',
    'assets/images/trash.png',
  ];
  double currentRating = 2.5;
  
  @override
  Widget build(BuildContext context) {
    currentRating = widget.movie.rating;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        elevation: 7.5,
        color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
            ? Theme.of(context).primaryColor
            : Theme.of(context).canvasColor,
        shadowColor: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(10),
        child: GFListTileCustom(
          avatar: ClipRRect(
              borderRadius: BorderRadius.circular(10), child: _generateImage()),
          titleText: widget.movie.title,
          subTitleText: widget.movie.getTileText(),
          subtitleTextColor: Theme.of(context).hintColor,
          listItemTextColor:
              Theme.of(context).navigationBarTheme.indicatorColor,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          icon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: SizedBox(
              width: 20,
              height: 100,
              child: RatingBar(
                initialRating: currentRating,
                direction: Axis.vertical,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                ratingWidget: RatingWidget(full: const Icon(Icons.star, color: Colors.yellow), half: const Icon(Icons.star_half, color: Colors.yellow,), empty: const Icon(Icons.star_border, color: Colors.yellow,)), 
                onRatingUpdate: (rating) {
                  _updateRating(rating);
              })
            ),
          ),
        ),
      ),
    );
  }
  /// Function that changes the rank/medal image and updates the changed Database entry
  _updateRating(rating) {
    setState(() {
      currentRating = rating;
      widget.movie.rating = currentRating;
    });
    log(currentRating.toString());
    GetIt.instance.get<UpdateMedium>().call(MovieModel(
        title: widget.movie.title,
        image: widget.movie.image,
        genres: widget.movie.genres,
        addedIn: widget.movie.addedIn,
        release: widget.movie.release,
        rating: currentRating,
        averageRating: widget.movie.averageRating,
        id: widget.movie.id));
  }
  /// Function that handles image loading
  _generateImage() {
    if (widget.movie.image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.movie.image,
        placeholder: ((context, url) =>
            Image.asset('assets/images/movie-placeholder.png')),
        height: 110,
        width: 75,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    } else {
      return Image.asset(
        'assets/images/movie-placeholder.png',
        height: 110,
        width: 75,
      );
    }
  }
}
