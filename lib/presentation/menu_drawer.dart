import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/domain/use_cases/empty_databse.dart';
import 'package:media_logging/domain/use_cases/export_database.dart';
import 'package:media_logging/domain/use_cases/import_database.dart';

/// MenuDrawer Widget which contains the options to export, import and reset
/// the database. Wanting to reset the database has to be confirmed to prevent
/// unwanted removal of all data

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({required this.refreshView, super.key});
  final Function refreshView;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 200, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // InkWell because Text does not have an onTap property
            InkWell(
              child: const Text(
                "Datenbank zurücksetzen",
                style: TextStyle(fontSize: 18, fontFamily: "verdana"),
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text("Datenbank wirklich zurücksetzen?"),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text("Abbrechen"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          CupertinoDialogAction(
                            child: const Text("Löschen"),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              await GetIt.instance.get<EmptyDatabase>().call();
                              refreshView();
                            },
                          )
                        ],
                      );
                    });
              },
            ),
            // SizedBox as padding in between InkWells
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                GetIt.instance.get<ExportDatabase>().call();
              },
              child: const Text(
                "Datenbank exportieren",
                style: TextStyle(fontSize: 18, fontFamily: "verdana"),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                await GetIt.instance.get<ImportDatabase>().call();
                refreshView();
              },
              child: const Text(
                "Datenbank importieren",
                style: TextStyle(fontSize: 18, fontFamily: "verdana"),
              ),
            ),
            const SizedBox(height: 500),
            Column(
              children: const [
                Text("Game-Daten von: IDGB"),
                Text("Film- und Serien-Daten von: TMDB"),
                Text("Buch-Daten von: Google Books"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
