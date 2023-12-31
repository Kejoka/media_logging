import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/domain/use_cases/empty_databse.dart';
import 'package:media_logging/domain/use_cases/export_database.dart';
import 'package:media_logging/domain/use_cases/import_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MenuDrawer Widget which contains the options to export, import and reset
/// the database. Wanting to reset the database has to be confirmed to prevent
/// unwanted removal of all data

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({required this.refreshView, super.key});
  final Function refreshView;

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  bool releaseLock = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      _fetchBool();
    });
  }

  void _fetchBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      releaseLock = prefs.getBool('release_lock') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 20, 0),
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
                              await GetIt.instance.get<EmptyDatabase>().call();
                              widget.refreshView();
                              Navigator.of(context).pop();
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
                await GetIt.instance.get<ImportDatabase>().call();
                widget.refreshView();
                Navigator.pop(context);
              },
              child: const Text(
                "Datenbank importieren",
                style: TextStyle(fontSize: 18, fontFamily: "verdana"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Releasefilter", style: TextStyle(fontSize: 18, fontFamily: "verdana"),),
                Checkbox(value: releaseLock, onChanged: (currentVal) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('release_lock', currentVal ?? true);
                    setState(() {
                      releaseLock = currentVal ?? true;
                    });
                }, 
                fillColor: MaterialStateProperty.resolveWith((states) {
                  return Theme.of(context).secondaryHeaderColor;
                }),)
              ],
            ),
            const SizedBox(height: 500),
            const Column(
              children: [
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
