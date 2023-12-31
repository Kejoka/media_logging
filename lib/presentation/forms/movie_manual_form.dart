import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/movie_model.dart';
import 'package:media_logging/domain/entities/movie.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';

/// Form that is responsible for editing existin as well as adding new entries
/// manually. The functionality changes depending on whether a movie
/// object is passed

class MovieManualForm extends StatefulWidget {
  const MovieManualForm({this.appMode, this.movie, super.key});
  final Movie? movie;
  final String? appMode;
  @override
  State<MovieManualForm> createState() => _MovieManualFormState();
}

class _MovieManualFormState extends State<MovieManualForm> {
  String? titleText;
  String? imageLink;
  List<String>? genreList;
  DateTime? newDate;
  String? dateText;
  double? ratingVal;
  DateTime addedIn = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.movie != null)
            ? const Text('Film bearbeiten')
            : const Text("Film manuell hinzufügen"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  titleText = value;
                });
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Titel"),
              initialValue: (widget.movie != null) ? widget.movie?.title : "",
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Genres (Kommaliste)"),
              onChanged: (value) {
                setState(() {
                  genreList = value.split(',');
                });
              },
              initialValue: (widget.movie != null)
                  ? widget.movie?.genres.fold("", (previousValue, element) {
                      if (element.isNotEmpty && previousValue != null) {
                        return previousValue += "$element,";
                      } else {
                        return previousValue;
                      }
                    })
                  : "",
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Durchschnittliche Bewertung"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  ratingVal = min(double.tryParse(value) ?? 0.0, 10.0);
                });
              },
              initialValue: (widget.movie != null)
                  ? widget.movie?.averageRating.toString()
                  : "",
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  imageLink = value;
                });
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Bild-URL"),
              initialValue: (widget.movie != null) ? widget.movie?.image : "",
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Erscheinungsdatum: ${(widget.movie?.release != null && dateText == null) ? "${widget.movie?.release?.day}.${widget.movie?.release?.month}.${widget.movie?.release?.year}" : (dateText != null) ? dateText : ""}"),
                IconButton(
                  onPressed: () async {
                    DateTime? chosenDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 250),
                        lastDate: DateTime.now());
                    if (chosenDate != null) {
                      setState(() {
                        newDate = chosenDate;
                        dateText =
                            "${chosenDate.day}.${chosenDate.month}.${chosenDate.year}";
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            (widget.movie == null && widget.appMode == "Medien-Regal")
                ? SizedBox(
                  height: 300,
                    child: YearPicker(
                        firstDate: DateTime(DateTime.now().year - 15),
                        lastDate: DateTime(DateTime.now().year + 1),
                        selectedDate: addedIn,
                        onChanged: (DateTime selectedYear) {
                          setState(() {
                            addedIn = selectedYear;
                          });
                        }),
                  )
                : Container(),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  int backlogVal = 0;
                  if (widget.appMode == "Backlog") {
                    backlogVal = 1;
                  }
                  if (widget.movie != null) {
                    // Despite the null check I still have to write movie? for some reason
                    await GetIt.instance.get<UpdateMedium>().call(MovieModel(
                        id: widget.movie?.id ?? -1,
                        title: titleText ?? widget.movie?.title ?? "",
                        image: imageLink ?? widget.movie?.image ?? "",
                        rating: widget.movie?.rating ?? 2.5,
                        averageRating:
                            ratingVal ?? widget.movie?.averageRating ?? 0.0,
                        release: newDate ?? widget.movie?.release,
                        addedIn: widget.movie?.addedIn ?? DateTime.now().year,
                        genres: genreList ?? widget.movie?.genres ?? [],
                        backlogged: backlogVal));
                  } else {
                    await GetIt.instance.get<CreateMedium>().call(MovieModel(
                          title: titleText ?? "Kein Titel",
                          image: imageLink ?? "",
                          rating: 2.5,
                          averageRating: ratingVal ?? 0.0,
                          release: newDate ?? DateTime.now(),
                          addedIn: addedIn.year,
                          genres: genreList ?? [],
                          backlogged: backlogVal
                        ));
                  }
                  Navigator.of(this.context).pop(addedIn);
                },
                child: (widget.movie != null)
                    ? const Text("Speichern")
                    : const Text("Hinzufügen"))
          ],
        ),
      ),
    );
  }
}
