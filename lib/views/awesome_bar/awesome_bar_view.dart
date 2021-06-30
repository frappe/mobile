import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/views/awesome_bar/awesome_bar_viewmodel.dart';
import 'package:frappe_app/widgets/card_list_tile.dart';

import '../../utils/frappe_icon.dart';

import '../../config/frappe_icons.dart';

import '../base_view.dart';

class Awesombar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();

    return BaseView<AwesomBarViewModel>(
      onModelReady: (model) {
        model.init();
      },
      builder: (context, model, child) {
        if (model.error != null) {
          return handleError(
            error: model.error,
            context: context,
            onRetry: () {
              model.refresh();
            },
          );
        } else {
          return Scaffold(
            appBar: searchBar(
              model: model,
              controller: textEditingController,
              context: context,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              child:
                  // model.recentSearchesMode
                  //     ? RecentSearches(
                  //         awesomeBarItems: model.recentSearches,
                  //         onItemTap: (awesomeBarItem) => model.onItemTap(
                  //           awesomeBarItem: awesomeBarItem,
                  //           context: context,
                  //         ),
                  //       )
                  //     :
                  SearchResults(
                awesomeBarItems: model.filteredAwesomeBarItems,
                onItemTap: (awesomeBarItem) => model.onItemTap(
                  awesomeBarItem: awesomeBarItem,
                  context: context,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  AppBar searchBar({
    required AwesomBarViewModel model,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return AppBar(
      elevation: 0.8,
      toolbarHeight: 90,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search'),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Flexible(
                flex: 5,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    model.toggleFocus(hasFocus);
                  },
                  child: TextField(
                    onChanged: (searchText) {
                      model.filterSearchItems(searchText);
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(
                          6,
                        ),
                      ),
                      fillColor: FrappePalette.grey[100],
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: FrappePalette.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                      hintText: "Search",
                      suffixIcon: model.hasFocus
                          ? InkWell(
                              onTap: () {
                                controller.clear();
                                model.filterSearchItems("");
                              },
                              child: CircleAvatar(
                                backgroundColor: FrappePalette.grey,
                                child: FrappeIcon(
                                  FrappeIcons.close_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FrappeIcon(
                          FrappeIcons.search,
                          color: FrappePalette.grey[700],
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minHeight: 42,
                        maxHeight: 42,
                      ),
                      suffixIconConstraints: BoxConstraints(
                        minHeight: 22,
                        maxHeight: 22,
                      ),
                    ),
                  ),
                ),
              ),
              if (model.hasFocus)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                    child: FlatButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: FrappePalette.blue[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      minWidth: 70,
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  final List<AwesomeBarItem> awesomeBarItems;
  final Function onItemTap;

  const SearchResults({
    required this.awesomeBarItems,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: awesomeBarItems.length > 5 ? 5 : awesomeBarItems.length,
      itemBuilder: (context, index) {
        var awesomeBarItem = awesomeBarItems[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: CardListTile(
            title: Text(
              awesomeBarItem.label,
              style: TextStyle(
                color: FrappePalette.grey[900],
              ),
            ),
            onTap: () async {
              onItemTap(
                awesomeBarItem,
              );
            },
          ),
        );
      },
    );
  }
}

// class RecentSearches extends StatelessWidget {
//   final List<AwesomeBarItem> awesomeBarItems;
//   final Function onItemTap;

//   const RecentSearches({
//     required this.awesomeBarItems,
//     required this.onItemTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Recent",
//             style: TextStyle(
//               color: FrappePalette.grey[700],
//             ),
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: awesomeBarItems.length > 5 ? 5 : awesomeBarItems.length,
//             itemBuilder: (context, index) {
//               var awesomeBarItem = awesomeBarItems[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 4,
//                 ),
//                 child: CardListTile(
//                   title: Text(
//                     awesomeBarItem.label,
//                     style: TextStyle(
//                       color: FrappePalette.grey[900],
//                     ),
//                   ),
//                   onTap: () async {
//                     onItemTap(
//                       awesomeBarItem,
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
