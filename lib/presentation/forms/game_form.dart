import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/data/models/game_model.dart';
import 'package:media_logging/domain/entities/game.dart';
import 'package:media_logging/domain/use_cases/create_medium.dart';
import 'package:media_logging/domain/use_cases/get_suggestions.dart';
import 'package:media_logging/presentation/forms/game_manual_form.dart';

/// Dialogbox which contains a Typeaheadfield that fetches game suggestions from igdb
/// based on the user input.

class Gameform extends StatefulWidget {
  final String? appMode;
  const Gameform({this.appMode, super.key});
  @override
  State<Gameform> createState() => _GameformState();
}

class _GameformState extends State<Gameform> {
  final TextEditingController _titleController = TextEditingController();
  DateTime year = DateTime.now();
  bool _suggestionChosen = false;
  late Game _chosenGame;
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
                      .call(pattern, "games", widget.appMode, addedIn: year.year);
                },
                suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                    constraints: BoxConstraints(
                  maxHeight: 380,
                )),
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.videogame_asset_rounded),
                    title: Text(suggestion.title),
                    subtitle: Text(
                        "Erschienen: ${suggestion.release?.day}.${suggestion.release?.month}.${suggestion.release?.year}"),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _titleController.text = suggestion.title;
                    _suggestionChosen = true;
                    _chosenGame = suggestion;
                  });
                },
              ),
              (widget.appMode == "Medien-Regal") ?
              Expanded(
                child: YearPicker(
                    firstDate: DateTime(DateTime.now().year - 25),
                    lastDate: DateTime(DateTime.now().year + 1),
                    selectedDate: year,
                    onChanged: (DateTime selectedYear) {
                      log(selectedYear.toString());
                      setState(() {
                        year = selectedYear;
                      });
                    }),
              ) : const SizedBox(width: 100, height: 20,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: _suggestionChosen ? () => _addGame(widget.appMode) : null,
                  child: const Text("Hinzufügen")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    DateTime? passedYear = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const GameManualForm()));
                    Navigator.pop(this.context, passedYear?.year);
                  },
                  child: const Text("Manuell hinzufügen"))
            ],
          ),
        ),
      ),
    ));
  }

  _addGame(String? appMode) async {
    int backlogVal = 0;
    if (appMode == "Backlog") {
      backlogVal = 1;
    }
    final game = GameModel(
        title: _chosenGame.title,
        image: _chosenGame.image,
        addedIn: year.year,
        release: _chosenGame.release,
        rating: 2.5,
        trophy: 0,
        genres: _chosenGame.genres,
        platforms: _chosenGame.platforms,
        averageRating: _chosenGame.averageRating,
        backlogged: backlogVal);
    GetIt.instance
        .get<CreateMedium>()
        .call(game)
        .then((_) => Navigator.pop(context, year.year));
  }
}
