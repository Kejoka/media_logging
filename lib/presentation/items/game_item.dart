import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/game_model.dart';
import 'package:media_logging/domain/entities/game.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';
import 'package:media_logging/presentation/custom_gf_list_tile.dart';

/// Tile that games information about a game. Uses the modified GF List Tile

class GameItem extends StatefulWidget {
  final Game game;
  final Function()? onTap;
  final Function()? onLongPress;
  final String? appMode;

  const GameItem({
    required this.game,
    this.onTap,
    this.onLongPress,
    this.appMode,
    Key? key,
  }) : super(key: key);

  @override
  State<GameItem> createState() => _GameItemState();
}

class _GameItemState extends State<GameItem> {
  final rankImageSelection = [
    'assets/images/blank.png',
    'assets/images/gold.png',
    'assets/images/silver.png',
    'assets/images/bronze.png',
    'assets/images/trash.png',
  ];
  final trophyImageSelection = [
    'assets/images/trophy-blank.png',
    'assets/images/platinum.png',
    'assets/images/100.png',
  ];
  double currentRating = 2.5;
  int currentTrophy = 0;

  @override
  Widget build(BuildContext context) {
    currentRating = widget.game.rating;
    currentTrophy = widget.game.trophy;
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
          titleText: widget.game.title,
          subTitleText: widget.game.getTileText(),
          subtitleTextColor: Theme.of(context).hintColor,
          subtitleFontSize: 12.5,
          listItemTextColor:
              Theme.of(context).navigationBarTheme.indicatorColor,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          icon: (widget.appMode == "Medien-Regal")
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: SizedBox(
                      width: 25,
                      height: 100,
                      child: RatingBar(
                          glowRadius: 1,
                          initialRating: currentRating,
                          direction: Axis.vertical,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 20,
                          ratingWidget: RatingWidget(
                              full:
                                  const Icon(Icons.star, color: Colors.yellow),
                              half: const Icon(
                                Icons.star_half,
                                color: Colors.yellow,
                              ),
                              empty: const Icon(
                                Icons.star_border,
                                color: Colors.yellow,
                              )),
                          onRatingUpdate: (rating) {
                            _updateRating(rating);
                          })),
                )
              : null,
        ),
      ),
    );
  }

  /// Function that changes the rank/rating image and updates the changed Database entry
  _updateRating(rating) {
    setState(() {
      currentRating = rating;
      widget.game.rating = currentRating;
    });
    GetIt.instance.get<UpdateMedium>().call(GameModel(
        title: widget.game.title,
        image: widget.game.image,
        addedIn: widget.game.addedIn,
        release: widget.game.release,
        rating: currentRating,
        trophy: widget.game.trophy,
        averageRating: widget.game.averageRating,
        id: widget.game.id,
        genres: widget.game.genres,
        platforms: widget.game.platforms,
        backlogged: widget.game.backlogged));
  }

  /// Function that handles image loading
  _generateImage() {
    if (widget.game.image.isNotEmpty) {
      return InkWell(
        onTap: (() {
          if (currentTrophy == trophyImageSelection.length - 1) {
            setState(() {
              currentTrophy = 0;
            });
          } else {
            setState(() {
              currentTrophy += 1;
            });
          }
          setState(() {
            widget.game.trophy = currentTrophy;
          });
          GetIt.instance.get<UpdateMedium>().call(GameModel(
              title: widget.game.title,
              image: widget.game.image,
              addedIn: widget.game.addedIn,
              release: widget.game.release,
              rating: widget.game.rating,
              trophy: currentTrophy,
              averageRating: widget.game.averageRating,
              id: widget.game.id,
              genres: widget.game.genres,
              platforms: widget.game.platforms,
              backlogged: widget.game.backlogged));
        }),
        child: Stack(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: widget.game.image,
              placeholder: ((context, url) =>
                  Image.asset('assets/images/game-placeholder.png')),
              height: 110,
              width: 75,
              fadeInDuration: const Duration(milliseconds: 200),
              fadeOutDuration: const Duration(milliseconds: 200),
            ),
            (currentTrophy != 0)
                ? Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Image.asset(trophyImageSelection[currentTrophy]),
                    ),
                  )
                : Container()
          ],
        ),
      );
    } else {
      return InkWell(
        onTap: (() {
          if (currentTrophy == trophyImageSelection.length - 1) {
            setState(() {
              currentTrophy = 0;
            });
          } else {
            setState(() {
              currentTrophy += 1;
            });
          }
          setState(() {
            widget.game.trophy = currentTrophy;
          });
          GetIt.instance.get<UpdateMedium>().call(GameModel(
              title: widget.game.title,
              image: widget.game.image,
              addedIn: widget.game.addedIn,
              release: widget.game.release,
              rating: widget.game.rating,
              trophy: currentTrophy,
              averageRating: widget.game.averageRating,
              id: widget.game.id,
              genres: widget.game.genres,
              platforms: widget.game.platforms,
              backlogged: widget.game.backlogged));
        }),
        child: Stack(
          children: <Widget>[
            Image.asset(
              'assets/images/game-placeholder.png',
              height: 110,
              width: 75,
            ),
            (currentTrophy != 0)
                ? Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      child: Image.asset(trophyImageSelection[currentTrophy]),
                    ),
                  )
                : Container()
          ],
        ),
      );
    }
  }
}

                // SizedBox(
                //   height: 50,
                //   child: IconButton(
                //     onPressed: _toggleTrophyImage,
                //     icon: Image.asset(trophyImageSelection[currentTrophy]),
                //   ),
                // ),
