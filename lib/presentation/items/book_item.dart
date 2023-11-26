import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/db_book_model.dart';
import 'package:media_logging/domain/entities/db_book.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';
import 'package:media_logging/presentation/custom_gf_list_tile.dart';

/// Tile that shows information about a book. Uses the modified GF List Tile

class BookItem extends StatefulWidget {
  final DbBook book;
  final Function()? onTap;
  final Function()? onLongPress;

  const BookItem({
    required this.book,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  State<BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
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
    currentRating = widget.book.rating;
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
          titleText: widget.book.title,
          subTitleText: widget.book.getTileText(),
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
      widget.book.rating = currentRating;
    });
    GetIt.instance.get<UpdateMedium>().call(DBBookModel(
        title: widget.book.title,
        subtitle: widget.book.subtitle,
        image: widget.book.image,
        addedIn: widget.book.addedIn,
        release: widget.book.release,
        rating: currentRating,
        author: widget.book.author,
        averageRating: widget.book.averageRating,
        pageCount: widget.book.pageCount,
        id: widget.book.id));
  }
  /// Function that handles image loading
  _generateImage() {
    if (widget.book.image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.book.image,
        placeholder: ((context, url) =>
            Image.asset('assets/images/book-placeholder.png')),
        height: 110,
        width: 75,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
      );
    } else {
      return Image.asset(
        'assets/images/book-placeholder.png',
        height: 110,
        width: 75,
      );
    }
  }
}
