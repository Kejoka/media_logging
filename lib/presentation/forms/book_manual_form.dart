import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/db_book_model.dart';
import 'package:media_logging/domain/entities/db_book.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/update_medium.dart';

/// Form that is responsible for editing existing book as well as adding new entries
/// manually. The functionality changes depending on whether a book
/// object is passed

class BookManualForm extends StatefulWidget {
  const BookManualForm({this.appMode, this.book, super.key});
  final DbBook? book;
  final String? appMode;
  @override
  State<BookManualForm> createState() => _BookManualFormState();
}

class _BookManualFormState extends State<BookManualForm> {
  String? titleText;
  String? subtitleText;
  String? authorText;
  String? dateText;
  String? imageLink;
  DateTime? newDate;
  double? ratingVal;
  int? pageCount;
  DateTime addedIn = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.book != null)
            ? const Text('Buch bearbeiten')
            : const Text("Buch manuell hinzufügen"),
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
              initialValue: (widget.book != null) ? widget.book?.title : "",
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Untertitel"),
              onChanged: (value) {
                setState(() {
                  subtitleText = value;
                });
              },
              initialValue: (widget.book != null) ? widget.book?.subtitle : "",
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Autor"),
              onChanged: (value) {
                setState(() {
                  authorText = value;
                });
              },
              initialValue: (widget.book != null) ? widget.book?.author : "",
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
              initialValue: (widget.book != null) ? widget.book?.image : "",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Durchschnittliche Bewertung"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        ratingVal = min(double.tryParse(value) ?? 0.0, 10.0);
                      });
                    },
                    initialValue: (widget.book != null)
                        ? widget.book?.averageRating.toString()
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
                        border: OutlineInputBorder(), labelText: "Seitenzahl"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        pageCount = int.tryParse(value);
                      });
                    },
                    initialValue: (widget.book != null)
                        ? widget.book?.pageCount.toString()
                        : "",
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Erscheinungsdatum: ${(widget.book?.release != null && dateText == null) ? "${widget.book?.release?.day}.${widget.book?.release?.month}.${widget.book?.release?.year}" : (dateText != null) ? dateText : ""}"),
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
            (widget.book == null && widget.appMode == "Medien-Regal")
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
                  if (widget.book != null) {
                    // Despite the null check I still have to write book? for some reason
                    await GetIt.instance.get<UpdateMedium>().call(DBBookModel(
                        id: widget.book?.id ?? -1,
                        title: titleText ?? widget.book?.title ?? "",
                        subtitle: subtitleText ?? widget.book?.subtitle ?? "",
                        image: imageLink ?? widget.book?.image ?? "",
                        author: authorText ?? widget.book?.author ?? "",
                        rating: widget.book?.rating ?? 2.5,
                        averageRating:
                            ratingVal ?? widget.book?.averageRating ?? 0.0,
                        pageCount: pageCount ?? widget.book?.pageCount ?? 0,
                        release: newDate ?? widget.book?.release,
                        addedIn: widget.book?.addedIn ?? DateTime.now().year,
                        backlogged: backlogVal));
                  } else {
                    await GetIt.instance.get<CreateMedium>().call(DBBookModel(
                        title: titleText ?? "Kein Titel",
                        subtitle: subtitleText ?? "",
                        image: imageLink ?? "",
                        author: authorText ?? "Unbekannter Autor",
                        rating: 2.5,
                        averageRating: ratingVal ?? 0.0,
                        pageCount: pageCount ?? 0,
                        release: newDate ?? DateTime.now(),
                        addedIn: addedIn.year,
                        backlogged: backlogVal));
                  }
                  Navigator.of(this.context).pop(addedIn);
                },
                child: (widget.book != null)
                    ? const Text("Speichern")
                    : const Text("Hinzufügen"))
          ],
        ),
      ),
    );
  }
}
