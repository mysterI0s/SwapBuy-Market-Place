import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swapbuy/Constant/text_styles.dart';
import 'package:swapbuy/View/User/Home/SearchPage/Controller/SearchPageController.dart';
import 'package:swapbuy/View/User/Home/SearchPage/SearchPageUi.dart'; // Assuming this is SearchResultsPage

class ProductSearchDelegate extends SearchDelegate {
  final SearchPageController controller;

  ProductSearchDelegate(this.controller);

  @override
  String get searchFieldLabel => 'Search';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Provide the existing controller to the SearchResultsPage
    return ChangeNotifierProvider<SearchPageController>.value(
      value: controller, // Use the controller passed to the delegate
      child: SearchResultsPage(query: query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Type to search products',
        style: TextStyles.pramed.copyWith(color: Colors.grey),
      ),
    );
  }
}
