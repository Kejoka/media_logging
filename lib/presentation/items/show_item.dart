
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/show_model.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';
import 'package:media_logging/presentation/custom_gf_list_tile.dart';
import 'package:media_logging/domain/entities/show.dart';

/// Tile that shows information about a show. Uses the modified GF List Tile

class ShowItem extends StatefulWidget {
  final Show show;
  final Function()? onTap;
  final Function()? onLongPress;

  const ShowItem({
    required this.show,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  State<ShowItem> createState() => _ShowItemState();
}

class _ShowItemState extends State<ShowItem> {
  final rankImageSelection = [
    'assets/images/blank.png',
    'assets/images/gold.png',
    'assets/images/silver.png',
    'assets/images/bronze.png',
    'assets/images/trash.png',
  ];
  double currentRating = 2.5;
  List<int> currentSeasons = [];
  int currentEpisode = 0;
  @override
  void initState() {
    super.initState();
    currentSeasons = [widget.show.seasonsA, widget.show.seasonsB];
  }

  @override
  Widget build(BuildContext context) {
    currentRating = widget.show.rating;
    currentEpisode = widget.show.episode;
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
          titleText: widget.show.title,
          subTitleText: widget.show.getTileText(),
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
      widget.show.rating = currentRating;
    });
    GetIt.instance.get<UpdateMedium>().call(ShowModel(
        title: widget.show.title,
        image: widget.show.image,
        genres: widget.show.genres,
        addedIn: widget.show.addedIn,
        release: widget.show.release,
        rating: currentRating,
        seasonsA: widget.show.seasonsA,
        seasonsB: widget.show.seasonsB,
        id: widget.show.id,
        averageRating: widget.show.averageRating,
        episode: currentEpisode));
  }
  /// Function that handles image loading
  _generateImage() {
    if (widget.show.image.isNotEmpty) {
      return InkWell(
        onTap: (() {
          setState(() {
            currentEpisode += 1;
            widget.show.episode = currentEpisode;
          });
          GetIt.instance.get<UpdateMedium>().call(ShowModel(
            title: widget.show.title,
            image: widget.show.image,
            genres: widget.show.genres,
            addedIn: widget.show.addedIn,
            release: widget.show.release,
            rating: widget.show.rating,
            seasonsA: widget.show.seasonsA,
            seasonsB: widget.show.seasonsB,
            id: widget.show.id,
            averageRating: widget.show.averageRating,
            episode: widget.show.episode));
        }),
        onLongPress: () {
          if (currentEpisode > 0) {
            setState(() {
              currentEpisode -= 1;
              widget.show.episode = currentEpisode;
            });
            GetIt.instance.get<UpdateMedium>().call(ShowModel(
              title: widget.show.title,
              image: widget.show.image,
              genres: widget.show.genres,
              addedIn: widget.show.addedIn,
              release: widget.show.release,
              rating: widget.show.rating,
              seasonsA: widget.show.seasonsA,
              seasonsB: widget.show.seasonsB,
              id: widget.show.id,
              averageRating: widget.show.averageRating,
              episode: widget.show.episode));
          }
        },
        child: Stack(
          children: <Widget>[CachedNetworkImage(
            imageUrl: widget.show.image,
            placeholder: ((context, url) =>
                Image.asset('assets/images/show-placeholder.png')),
            height: 110,
            width: 75,
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 200),
          ), 
          (currentEpisode != 0) ?
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Container(
              width: 20, 
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Theme.of(context).hintColor),
                shape: BoxShape.circle,
                color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).canvasColor
              ),
              alignment: Alignment.center,
              child: Text(currentEpisode.toString(), style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11.5),),
            ),
          ) : Container()],
        ),
      );
    } else {
      return InkWell(
        onTap: (() {
          setState(() {
            currentEpisode += 1;
            widget.show.episode = currentEpisode;
          });
          GetIt.instance.get<UpdateMedium>().call(ShowModel(
            title: widget.show.title,
            image: widget.show.image,
            genres: widget.show.genres,
            addedIn: widget.show.addedIn,
            release: widget.show.release,
            rating: widget.show.rating,
            seasonsA: widget.show.seasonsA,
            seasonsB: widget.show.seasonsB,
            id: widget.show.id,
            averageRating: widget.show.averageRating,
            episode: widget.show.episode));
        }),
        onLongPress: () {
          if (currentEpisode > 0) {
            setState(() {
              currentEpisode -= 1;
              widget.show.episode = currentEpisode;
            });
            GetIt.instance.get<UpdateMedium>().call(ShowModel(
              title: widget.show.title,
              image: widget.show.image,
              genres: widget.show.genres,
              addedIn: widget.show.addedIn,
              release: widget.show.release,
              rating: widget.show.rating,
              seasonsA: widget.show.seasonsA,
              seasonsB: widget.show.seasonsB,
              id: widget.show.id,
              averageRating: widget.show.averageRating,
              episode: widget.show.episode));
          }
        },
        child: Stack(
          children: <Widget>[Image.asset(
        'assets/images/show-placeholder.png',
        height: 110,
        width: 75,
      ), 
          (currentEpisode != 0) ?
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Container(
              width: 20, 
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Theme.of(context).hintColor),
                shape: BoxShape.circle,
                color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).canvasColor
              ),
              alignment: Alignment.center,
              child: Text(currentEpisode.toString(), style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11.5),),
            ),
          ) : Container()],
        ),
      );
    }
  }
}
