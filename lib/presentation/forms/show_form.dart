import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/show_model.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/get_genres.dart';
import 'package:media_logging/domain/use_cases/get_suggestions.dart';
import 'package:media_logging/domain/use_cases/get_tmdb_image_url.dart';
import 'package:media_logging/presentation/forms/show_manual_form.dart';

/// Dialogbox which contains a TypeAheadField that fetches show suggestions from tmdb
/// based on the user input

class ShowForm extends StatefulWidget {
  final String? appMode;
  const ShowForm({this.appMode, super.key});

  @override
  State<ShowForm> createState() => _ShowFormState();
}

class _ShowFormState extends State<ShowForm> {
  final TextEditingController _titleController = TextEditingController();
  DateTime year = DateTime.now();
  bool _suggestionChosen = false;
  dynamic _chosenShow;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: (widget.appMode == "Medien-Regal") ? 500 : 200,
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
                      .call(pattern, "shows", widget.appMode);
                },
                suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                    constraints: BoxConstraints(
                  maxHeight: 380,
                )),
                itemBuilder: (context, suggestion) {
                  DateTime? release =
                      DateTime.tryParse(suggestion["first_air_date"]);
                  return ListTile(
                    leading: const Icon(Icons.movie_rounded),
                    title: Text(suggestion["name"].toString()),
                    subtitle: Text(
                        "Premiere: ${release?.day}.${release?.month}.${release?.year}"),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _titleController.text = suggestion["name"].toString();
                    _suggestionChosen = true;
                    _chosenShow = suggestion;
                  });
                },
              ),
              (widget.appMode == "Medien-Regal") ? Expanded(
                child: YearPicker(
                    firstDate: DateTime(DateTime.now().year - 15),
                    lastDate: DateTime(DateTime.now().year + 1),
                    selectedDate: year,
                    onChanged: (DateTime selectedYear) {
                      setState(() {
                        year = selectedYear;
                      });
                    }),
              ) : const SizedBox(width: 100, height: 20,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: _suggestionChosen ? () => _addShow(widget.appMode) : null,
                  child: const Text("Hinzufügen")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    DateTime? passedYear = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ShowManualForm()));
                    Navigator.pop(this.context, passedYear?.year);
                  },
                  child: const Text("Manuell hinzufügen"))
            ],
          ),
        ),
      ),
    ));
  }

  _addShow(String? appMode) async {
    int backlogVal = 0;
    if (appMode == "Backlog") {
      backlogVal = 1;
    }
    var genres = await GetIt.instance
        .get<GetGenres>()
        .call(_chosenShow["genre_ids"], "shows");
    var imageURL = "";
    if (_chosenShow["poster_path"] != null) {
      imageURL = await GetIt.instance
          .get<GetTMDBImageURL>()
          .call(_chosenShow["poster_path"]);
    }
    final show = ShowModel(
        title: _chosenShow["name"],
        image: imageURL,
        genres: genres,
        addedIn: year.year,
        release: DateTime.tryParse(_chosenShow["first_air_date"]),
        rating: 2.5,
        seasonsA: 0,
        seasonsB: 0,
        episode: 0,
        backlogged: backlogVal,
      /// API changed the amount of decimals from 1 to 3 during development and this
      /// seems like the simplest way to ensure consitent formatting
      averageRating: double.tryParse(
              _chosenShow["vote_average"].toDouble().toStringAsFixed(1)) ??
          _chosenShow["vote_average"].toDouble(),
    );
    GetIt.instance
        .get<CreateMedium>()
        .call(show)
        .then((value) => Navigator.pop(context, year.year));
  }
}
