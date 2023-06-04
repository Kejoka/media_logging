import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/db_book_model.dart';
import 'package:books_finder/books_finder.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/get_suggestions.dart';
import 'package:media_logging/presentation/forms/book_manual_form.dart';

/// Dialogbox which contains a Typeaheadfield that fetches book suggestions from google books
/// based on the user input.

class BookForm extends StatefulWidget {
  const BookForm({super.key});
  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final TextEditingController _titleController = TextEditingController();
  DateTime year = DateTime.now();
  bool _suggestionChosen = false;
  late Book _chosenBook;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 500,
          child: Column(
            children: [
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                    controller: _titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              _titleController.clear();
                            },
                            icon: const Icon(Icons.clear)),
                        border: const OutlineInputBorder(),
                        labelText: "Titel")),
                suggestionsCallback: (pattern) async {
                  return await GetIt.instance
                      .get<GetSuggestions>()
                      .call(pattern, "books");
                },
                suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                    constraints: BoxConstraints(
                  maxHeight: 380,
                )),
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.book_rounded),
                    title: Text(suggestion.info.title),
                    subtitle: Text(
                        "${suggestion.info.authors.first}\n${suggestion.info.publishedDate?.day}.${suggestion.info.publishedDate?.month}.${suggestion.info.publishedDate?.year}"),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _titleController.text = suggestion.info.title;
                    _suggestionChosen = true;
                    _chosenBook = suggestion;
                  });
                },
              ),
              Expanded(
                child: YearPicker(
                    firstDate: DateTime(DateTime.now().year - 15),
                    lastDate: DateTime(DateTime.now().year + 1),
                    selectedDate: year,
                    onChanged: (DateTime selectedYear) {
                      log(selectedYear.toString());
                      setState(() {
                        year = selectedYear;
                      });
                    }),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: _suggestionChosen ? _addBook : null,
                  child: const Text("Hinzufügen")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    DateTime? passedYear = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const BookManualForm()));
                    Navigator.pop(this.context, passedYear?.year);
                  },
                  child: const Text("Manuell hinzufügen"))
            ],
          ),
        ),
      ),
    ));
  }

  _addBook() async {
    final book = DBBookModel(
        title: _chosenBook.info.title,
        subtitle: _chosenBook.info.subtitle,
        image: (_chosenBook.info.imageLinks.isNotEmpty)
            ? _chosenBook.info.imageLinks.values.first.toString()
            : "",
        addedIn: year.year,
        release: DateTime.tryParse(_chosenBook.info.rawPublishedDate),
        medal: 0,
        author: _chosenBook.info.authors.first,
        averageRating: _chosenBook.info.averageRating,
        pageCount: _chosenBook.info.pageCount);
    GetIt.instance
        .get<CreateMedium>()
        .call(book)
        .then((_) => Navigator.pop(context, year.year));
  }
}
