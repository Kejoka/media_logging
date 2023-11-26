import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:media_logging/domain/use_cases/get_year_list.dart';
import 'package:media_logging/presentation/forms/book_manual_form.dart';
import 'package:media_logging/presentation/forms/game_manual_form.dart';
import 'package:media_logging/presentation/forms/movie_manual_form.dart';
import 'package:media_logging/presentation/forms/show_manual_form.dart';
import 'package:media_logging/presentation/list_view_builder.dart';
import 'package:media_logging/presentation/forms/book_form.dart';
import 'package:media_logging/presentation/forms/movie_form.dart';
import 'package:media_logging/presentation/forms/game_form.dart';
import 'package:media_logging/presentation/forms/show_form.dart';
import 'package:media_logging/presentation/menu_drawer.dart';
import 'package:media_logging/presentation/year_selector.dart';

/// The MediaNavigator widget is the "skeleton" of the app
/// Contains the AppBar as well

class MediaNavigator extends StatefulWidget {
  const MediaNavigator({super.key});

  @override
  State<MediaNavigator> createState() => _MediaNavigatorState();
}

class _MediaNavigatorState extends State<MediaNavigator>
    with TickerProviderStateMixin {
  // 0 = Media List View, 1 = Statistics View
  var _appMode = "Medien-Regal";
  final _appModeTexts = ["Medien-Regal", "Backlog", "Statistiken"];
  var _selectedYear = DateTime.now().year;
  dynamic _tabBarController;
  /// Different ListViewBuilders for each media type which are represented as their
  /// corresponding tabbar index
  ListViewBuilder _gameListBuilder = ListViewBuilder(
    mediaIndex: 0,
    filterYear: DateTime.now().year,
    appMode: "Medien-Regal",
  );
  ListViewBuilder _movieListBuilder = ListViewBuilder(
    mediaIndex: 1,
    filterYear: DateTime.now().year,
    appMode: "Medien-Regal",
  );
  ListViewBuilder _showListBuilder = ListViewBuilder(
    mediaIndex: 2,
    filterYear: DateTime.now().year,
    appMode: "Medien-Regal",
  );
  ListViewBuilder _bookListBuilder = ListViewBuilder(
    mediaIndex: 3,
    filterYear: DateTime.now().year,
    appMode: "Medien-Regal",
  );

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(length: 4, vsync: this, initialIndex: 1);
    /// Had to use a custom TabController since the default controller does not
    /// listen to the swipe gesture when onTap is defined
    _tabBarController.addListener(() {
      _selectedYear = DateTime.now().year;
      if (_appMode == "Medien-Regal") {
        _refreshMediaViewsFull();
      } else {
        // Refreshing all views in statistics mode caused some errors
        _refreshMediaView(_selectedYear);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
          // Dark mode colors that I chose did not look good in light mode
          backgroundColor:
              (MediaQuery.of(context).platformBrightness == Brightness.dark)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).canvasColor,
          appBar: AppBar(
            backgroundColor:
                (MediaQuery.of(context).platformBrightness == Brightness.dark)
                    ? Theme.of(context).canvasColor
                    : Theme.of(context).appBarTheme.backgroundColor,
            title: DropdownMenu<String>(
              textStyle: const TextStyle(
                fontSize: 20,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: InputBorder.none
              ),
              initialSelection: _appModeTexts.first,
              onSelected: (String? value) {
                _appMode = value ?? "Medien-Regal";
                _refreshMediaViewsFull();
              },
              dropdownMenuEntries: _appModeTexts.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value,);
              }).toList(),
            ),
            bottom: TabBar(
              controller: _tabBarController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.videogame_asset_rounded),
                  text: "Games",
                ),
                Tab(
                  icon: Icon(Icons.movie_rounded),
                  text: "Filme",
                ),
                Tab(
                  icon: Icon(Icons.tv_rounded),
                  text: "Serien",
                ),
                Tab(
                  icon: Icon(Icons.book_rounded),
                  text: "Bücher",
                )
              ],
            ),
          ),
          // Menudrawer need the ability to refresh all media views after manipulating the entire database
          endDrawer: MenuDrawer(refreshView: _refreshMediaViewsFull),
          body: TabBarView(controller: _tabBarController, children: [
            _gameListBuilder,
            _movieListBuilder,
            _showListBuilder,
            _bookListBuilder,
          ]),
          bottomNavigationBar: FutureBuilder(
              future: GetIt.instance
                  .get<GetYearList>()
                  .call(_tabBarController.index),
              builder: ((context, snapshot) {
                final years = snapshot.data ?? [];
                if (snapshot.hasData) {
                  return YearSelector(
                      years: years,
                      currentYear: _selectedYear,
                      refreshView: _refreshMediaView);
                }
                return Container();
              })),
          floatingActionButton: _getFloatingActionButton());
    });
  }

  /// FloatingActionButton moved to a function for readability.
  /// The FloatingActionButton will only be shown if the appmode is 0 (media-view)
  _getFloatingActionButton() {
    if (_appMode == "Medien-Regal") {
      return FloatingActionButton(
        onPressed: _showForm,
        // Dark mode colors I chose did not look good in light mode
        backgroundColor:
            (MediaQuery.of(context).platformBrightness == Brightness.dark)
                ? Theme.of(context).canvasColor
                : Theme.of(context).appBarTheme.backgroundColor,
        child: Icon(Icons.add_rounded, color: Theme.of(context).hintColor),
      );
    } else {
      return Container();
    }
  }

  /// Will either show a Dialog if there is internet connectivity or directly
  /// open the form that allows the user to add a media type manually
  /// without fetching data from any api
  _showForm() async {
    await (Connectivity().checkConnectivity()).then((connectivityResult) async {
      if (connectivityResult != ConnectivityResult.mobile &&
          connectivityResult != ConnectivityResult.wifi) {
        switch (_tabBarController.index) {
          case 0:
            await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GameManualForm()));
            return;
          case 1:
            await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MovieManualForm()));
            return;
          case 2:
            await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShowManualForm()));
            return;
          case 3:
            await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BookManualForm()));
            return;
        }
      } else {
        var addedYear = await showDialog(
            context: context,
            builder: (BuildContext context) {
              switch (_tabBarController.index) {
                case 0:
                  return const Gameform();
                case 1:
                  return const MovieForm();
                case 2:
                  return const ShowForm();
                case 3:
                  return const BookForm();
                default:
                  return Container();
              }
            });
        // If something was added to the DB switch the current year to the year
        // of the recently added medium
        if (addedYear != null) {
          _refreshMediaView(addedYear);
        }
      }
    });
  }

  /// Function that is passed as a callback to YearSelector. Refreshes the
  /// currently selected year and the current MediaView
  void _refreshMediaView(int year) {
    setState(() {
      _selectedYear = year;
      switch (_tabBarController.index) {
        case 0:
          _gameListBuilder = ListViewBuilder(
            mediaIndex: 0,
            filterYear: _selectedYear,
            appMode: _appMode,
          );
          break;
        case 1:
          _movieListBuilder = ListViewBuilder(
            mediaIndex: 1,
            filterYear: _selectedYear,
            appMode: _appMode,
          );
          break;
        case 2:
          _showListBuilder = ListViewBuilder(
            mediaIndex: 2,
            filterYear: _selectedYear,
            appMode: _appMode,
          );
          break;
        case 3:
          _bookListBuilder = ListViewBuilder(
            mediaIndex: 3,
            filterYear: _selectedYear,
            appMode: _appMode,
          );
          break;
        default:
      }
    });
  }

  /// Function that refreshes all Media Views. Used when "global" changes have
  /// been made (like importing a database) so the user won't be able to see
  /// old entires when swiing to another MediaType
  void _refreshMediaViewsFull() {
    setState(() {
      _gameListBuilder = ListViewBuilder(
        mediaIndex: 0,
        filterYear: _selectedYear,
        appMode: _appMode,
      );
      _movieListBuilder = ListViewBuilder(
        mediaIndex: 1,
        filterYear: _selectedYear,
        appMode: _appMode,
      );
      _showListBuilder = ListViewBuilder(
        mediaIndex: 2,
        filterYear: _selectedYear,
        appMode: _appMode,
      );
      _bookListBuilder = ListViewBuilder(
        mediaIndex: 3,
        filterYear: _selectedYear,
        appMode: _appMode,
      );
    });
  }
}
