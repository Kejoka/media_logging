import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/game_model.dart';
import 'package:media_logging/domain/entities/game.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';
import 'package:media_logging/presentation/custom_gf_list_tile.dart';

/// Tile that shows information about a game. Uses the modified GF List Tile

class GameItem extends StatefulWidget {
  final Game game;
  final Function()? onTap;
  final Function()? onLongPress;

  const GameItem({
    required this.game,
    this.onTap,
    this.onLongPress,
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
  int currentRank = 0;
  int currentTrophy = 0;

  @override
  Widget build(BuildContext context) {
    currentRank = widget.game.medal;
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
          icon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleTrophyImage,
                  icon: Image.asset(trophyImageSelection[currentTrophy]),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: _toggleRankImage,
                  icon: Image.asset(rankImageSelection[currentRank]),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// Function that changes the rank/medal image and updates the changed Database entry
  _toggleRankImage() {
    if (currentRank == rankImageSelection.length - 1) {
      setState(() {
        currentRank = 0;
      });
    } else {
      setState(() {
        currentRank += 1;
      });
    }
    setState(() {
      widget.game.medal = currentRank;
    });
    GetIt.instance.get<UpdateMedium>().call(GameModel(
        title: widget.game.title,
        image: widget.game.image,
        addedIn: widget.game.addedIn,
        release: widget.game.release,
        medal: currentRank,
        trophy: widget.game.trophy,
        averageRating: widget.game.averageRating,
        id: widget.game.id,
        genres: widget.game.genres,
        platforms: widget.game.platforms));
  }
  /// Function that changes the trophy/completion image and updates the changed Database entry
  _toggleTrophyImage() {
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
        medal: widget.game.medal,
        trophy: currentTrophy,
        averageRating: widget.game.averageRating,
        id: widget.game.id,
        genres: widget.game.genres,
        platforms: widget.game.platforms));
  }
  /// Function that handles image loading
  _generateImage() {
    if (widget.game.image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.game.image,
        placeholder: ((context, url) =>
            Image.asset('assets/images/game-placeholder.png')),
        height: 110,
        width: 75,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    } else {
      return Image.asset(
        'assets/images/game-placeholder.png',
        height: 110,
        width: 75,
      );
    }
  }
}
