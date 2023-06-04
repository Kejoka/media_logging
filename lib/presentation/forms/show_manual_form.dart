import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/show_model.dart';
import 'package:media_logging/domain/entities/show.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';

/// Form that is responsible for editing existing show as well as adding new entries
/// manually. The functionality changes depending on whether a show
/// object is passed

class ShowManualForm extends StatefulWidget {
  const ShowManualForm({this.show, super.key});
  final Show? show;
  @override
  State<ShowManualForm> createState() => _ShowManualFormState();
}

class _ShowManualFormState extends State<ShowManualForm> {
  String? titleText;
  String? imageLink;
  List<String>? genreList;
  DateTime? newDate;
  String? dateText;
  double? ratingVal;
  List<int?> seasonNums = [null, null];
  DateTime addedIn = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.show != null)
            ? const Text('Serie bearbeiten')
            : const Text("Serie manuell hinzufügen"),
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
              initialValue: (widget.show != null) ? widget.show?.title : "",
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
              initialValue: (widget.show != null)
                  ? widget.show?.genres.fold("", (previousValue, element) {
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
              initialValue: (widget.show != null)
                  ? widget.show?.averageRating.toString()
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
              initialValue: (widget.show != null) ? widget.show?.image : "",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Von Staffel"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        seasonNums[0] = int.tryParse(value);
                      });
                    },
                    initialValue: (widget.show != null)
                        ? widget.show?.seasonsA.toString()
                        : "",
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Bis Staffel"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        seasonNums[1] = int.tryParse(value);
                      });
                    },
                    initialValue: (widget.show != null)
                        ? widget.show?.seasonsB.toString()
                        : "",
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Erscheinungsdatum: ${(widget.show?.release != null && dateText == null) ? "${widget.show?.release?.day}.${widget.show?.release?.month}.${widget.show?.release?.year}" : (dateText != null) ? dateText : ""}"),
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
            (widget.show == null)
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
                  if (seasonNums[0] == null && seasonNums[1] != null) {
                    seasonNums[0] = seasonNums[1];
                  }
                  if (widget.show != null) {
                    // Despite the null check I still have to write show? for some reason
                    await GetIt.instance.get<UpdateMedium>().call(ShowModel(
                          id: widget.show?.id ?? -1,
                          title: titleText ?? widget.show?.title ?? "",
                          image: imageLink ?? widget.show?.image ?? "",
                          medal: widget.show?.medal ?? 0,
                          averageRating:
                              ratingVal ?? widget.show?.averageRating ?? 0.0,
                          release: newDate ?? widget.show?.release,
                          addedIn: widget.show?.addedIn ?? DateTime.now().year,
                          genres: genreList ?? widget.show?.genres ?? [],
                          seasonsA: seasonNums[0] ?? widget.show?.seasonsA ?? 0,
                          seasonsB: seasonNums[1] ?? widget.show?.seasonsB ?? 0,
                          episode: widget.show?.episode ?? 0
                        ));
                  } else {
                    await GetIt.instance.get<CreateMedium>().call(ShowModel(
                          title: titleText ?? "Kein Titel",
                          image: imageLink ?? "",
                          medal: 0,
                          averageRating: ratingVal ?? 0.0,
                          release: newDate ?? DateTime.now(),
                          addedIn: addedIn.year,
                          genres: genreList ?? [],
                          seasonsA: seasonNums[0] ?? 0,
                          seasonsB: seasonNums[1] ?? 0,
                          episode: 0
                        ));
                  }
                  Navigator.of(this.context).pop(addedIn);
                },
                child: (widget.show != null)
                    ? const Text("Speichern")
                    : const Text("Hinzufügen"))
          ],
        ),
      ),
    );
  }
}
