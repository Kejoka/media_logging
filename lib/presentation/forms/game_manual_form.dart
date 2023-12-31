import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/game_model.dart';
import 'package:media_logging/domain/entities/game.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';

/// Form that is responsible for editing existing game as well as adding new entries
/// manually. The functionality changes depending on whether a game
/// object is passed

class GameManualForm extends StatefulWidget {
  const GameManualForm({this.appMode, this.game, super.key});
  final Game? game;
  final String? appMode;
  @override
  State<GameManualForm> createState() => _GameManualFormState();
}

class _GameManualFormState extends State<GameManualForm> {
  String? titleText;
  String? imageLink;
  List<String>? genreList;
  DateTime? newDate;
  String? dateText;
  List<String>? platformList;
  double? ratingVal;
  DateTime addedIn = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.game != null)
            ? const Text('Game bearbeiten')
            : const Text("Game manuell hinzufügen"),
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
              initialValue: (widget.game != null) ? widget.game?.title : "",
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
              initialValue: (widget.game != null)
                  ? widget.game?.genres.fold("", (previousValue, element) {
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
                  labelText: "Plattformen (Kommaliste)"),
              onChanged: (value) {
                setState(() {
                  platformList = value.split(',');
                });
              },
              initialValue: (widget.game != null)
                  ? widget.game?.platforms.fold("", (previousValue, element) {
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
              initialValue: (widget.game != null)
                  ? widget.game?.averageRating.toString()
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
              initialValue: (widget.game != null) ? widget.game?.image : "",
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Erscheinungsdatum: ${(widget.game?.release != null && dateText == null) ? "${widget.game?.release?.day}.${widget.game?.release?.month}.${widget.game?.release?.year}" : (dateText != null) ? dateText : ""}"),
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
            (widget.game == null && widget.appMode == "Medien-Regal")
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
                  if (widget.game != null) {
                    // Despite the null check I still have to write game? for some reason
                    await GetIt.instance.get<UpdateMedium>().call(GameModel(
                        id: widget.game?.id ?? -1,
                        title: titleText ?? widget.game?.title ?? "",
                        image: imageLink ?? widget.game?.image ?? "",
                        rating: widget.game?.rating ?? 2.5,
                        averageRating:
                            ratingVal ?? widget.game?.averageRating ?? 0.0,
                        release: newDate ?? widget.game?.release,
                        addedIn: widget.game?.addedIn ?? DateTime.now().year,
                        genres: genreList ?? widget.game?.genres ?? [],
                        platforms: platformList ?? widget.game?.platforms ?? [],
                        trophy: widget.game?.trophy ?? 0,
                        backlogged: backlogVal));
                  } else {
                    await GetIt.instance.get<CreateMedium>().call(GameModel(
                        title: titleText ?? "Kein Titel",
                        image: imageLink ?? "",
                        rating: 2.5,
                        averageRating: ratingVal ?? 0.0,
                        release: newDate ?? DateTime.now(),
                        addedIn: addedIn.year,
                        genres: genreList ?? [],
                        platforms: platformList ?? [],
                        trophy: 0,
                        backlogged: backlogVal));
                  }
                  Navigator.of(this.context).pop(addedIn);
                },
                child: (widget.game != null)
                    ? const Text("Speichern")
                    : const Text("Hinzufügen"))
          ],
        ),
      ),
    );
  }
}
