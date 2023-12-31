import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/movie_model.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/get_genres.dart';
import 'package:media_logging/domain/use_cases/get_suggestions.dart';
import 'package:media_logging/domain/use_cases/get_tmdb_image_url.dart';
import 'package:media_logging/presentation/forms/movie_manual_form.dart';

/// Dialogbox which contains a Typeaheadfield that fetches movie suggestions from tmdb
/// based on the user input.

class MovieForm extends StatefulWidget {
  final String? appMode;
  const MovieForm({this.appMode, super.key});
  @override
  State<MovieForm> createState() => _MovieFormState();
}

class _MovieFormState extends State<MovieForm> {
  final TextEditingController _titleController = TextEditingController();
  DateTime year = DateTime.now();
  bool _suggestionChosen = false;
  dynamic _chosenMovie;
  int? _searchYear;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: (widget.appMode == "Medien-Regal") ? 500 : 275,
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
                          .call(pattern, "movies", widget.appMode, queryYear: _searchYear);
                    },
                    suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                        constraints: BoxConstraints(
                      maxHeight: 380,
                    )),
                    itemBuilder: (context, suggestion) {
                      DateTime? release =
                          DateTime.tryParse(suggestion["release_date"]);
                      return ListTile(
                        leading: const Icon(Icons.movie_rounded),
                        title: Text(suggestion["title"].toString()),
                        subtitle: Text(
                            "Erschienen: ${release?.day}.${release?.month}.${release?.year}"),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        _titleController.text = suggestion["title"].toString();
                        _suggestionChosen = true;
                        _chosenMovie = suggestion;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _searchYear = int.tryParse(value);
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Optional: Erscheinungsjahr"),
                  ),
                  (widget.appMode == "Medien-Regal") ? Expanded(
                    child: YearPicker(
                        firstDate: DateTime(DateTime.now().year - 25),
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
                      onPressed: _suggestionChosen ? () => _addMovie(widget.appMode) : null,
                      child: const Text("Hinzufügen")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        DateTime? passedYear = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const MovieManualForm()));
                        Navigator.pop(this.context, passedYear?.year);
                      },
                      child: const Text("Manuell hinzufügen"))
                ],
              ),
            ),
          ),
        ));
  }

  _addMovie(String? appMode) async {
    int backlogVal = 0;
    if (appMode == "Backlog") {
      backlogVal = 1;
    }
    final genres = await GetIt.instance
        .get<GetGenres>()
        .call(_chosenMovie["genre_ids"], "movies");
    var imageURL = "";
    if (_chosenMovie["poster_path"] != null) {
      imageURL = await GetIt.instance
          .get<GetTMDBImageURL>()
          .call(_chosenMovie["poster_path"]);
    }
    final movie = MovieModel(
        title: _chosenMovie["title"],
        image: imageURL,
        genres: genres,
        addedIn: year.year,
        release: DateTime.tryParse(_chosenMovie["release_date"]),
        /// API changed the amount of decimals from 1 to 3 during development and this
        /// seems like the simplest way to ensure consitent formatting
        averageRating: double.tryParse(
                _chosenMovie["vote_average"].toDouble().toStringAsFixed(1)) ??
            _chosenMovie["vote_average"].toDouble(),
        rating: 2.5,
        backlogged: backlogVal);
    GetIt.instance
        .get<CreateMedium>()
        .call(movie)
        .then((_) => Navigator.pop(context, year.year));
  }
}
