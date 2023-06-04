import 'package:flutter/material.dart';

/// Widget that serves as the bottomNavigationBar
/// Column with a horizontal scrollable SingleChildScrollView containing
/// ElevatedButtons which will grow in size and change color if their assigned
/// value (year from DB) matches the currently selected year. Also refreshes the
/// ListView's content according to its year value via a callback function
/// StatfulWidget so the ElevatedButtons have access to BuildContext

class YearSelector extends StatefulWidget {
  const YearSelector(
      {required this.years,
      required this.currentYear,
      required this.refreshView,
      super.key});

  final dynamic years;
  final int currentYear;
  final Function refreshView;

  @override
  State<YearSelector> createState() => _YearSelectorState();
}

class _YearSelectorState extends State<YearSelector> {
  @override
  Widget build(BuildContext context) {
    if (widget.years.isNotEmpty) {
      return Ink(
        // Theme.canvasColor looks good in dark mode but didn't look right in light mode
        color: (MediaQuery.of(context).platformBrightness == Brightness.dark)
            ? Theme.of(context).canvasColor
            : Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: SingleChildScrollView(
                // This is so you always see the current year on start
                reverse: true,
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _generateElevatedButtonList(
                      widget.years, widget.currentYear, widget.refreshView),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
  }

  /// Returns a list of ElevatedButtons
  _generateElevatedButtonList(
      List years, int currentYear, Function refreshView) {
    return years
        .map((e) => ElevatedButton(
              onPressed: () {
                /// Function from media_navigator.dart passed to each button so they are able
                /// to refresh the current list view
                refreshView(e);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (MediaQuery.of(context).platformBrightness ==
                        Brightness.dark)
                    ? Theme.of(context).canvasColor
                    : Theme.of(context).primaryColor,
                foregroundColor: e == currentYear
                    ? Theme.of(context).textTheme.displaySmall?.color
                    : Theme.of(context).disabledColor,
                textStyle: TextStyle(fontSize: e == currentYear ? 20 : 15),
                elevation: 0,
              ),
              child: Text(e.toString()),
            ))
        .toList();
  }
}
