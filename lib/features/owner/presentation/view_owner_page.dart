import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/owner/data/owner_model.dart';
import 'package:loan_app/features/owner/presentation/add_owner_page.dart';
import 'package:loan_app/features/owner/data/owner_repository.dart';
import 'package:loan_app/features/owner/presentation/update_owner_page.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/dialog_box.dart';
import 'package:loan_app/widgets/list_card.dart';
import 'package:loan_app/widgets/search_bar.dart';

class ViewOwnerPage extends StatefulWidget {
  @override
  ViewOwnerPageState createState() => ViewOwnerPageState();
}

class ViewOwnerPageState extends State<ViewOwnerPage> {
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final OwnerRepository ownerRepository = OwnerRepository();

  List<DocumentSnapshot> owners = [];
  DocumentSnapshot? lastDocument;
  bool isFetching = false;
  String? selectedFilter;
  bool isFilterApplied = false;
  String searchQuery = "";
  bool hasMoreData = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchOwners();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchOwners(isLoadMore: true);
    }
  }

  // Handle search input
  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      // print('Search query: $searchQuery');
      lastDocument = null;
      owners.clear(); // Reset list
      hasMoreData = true;
    });
    fetchOwners();
  }

  /// Fetch initial owners or more owners when paginating
  Future<void> fetchOwners({bool isLoadMore = false}) async {
    if (isFetching || (!hasMoreData && isLoadMore)) return;

    setState(() {
      isFetching = true;
      errorMessage = null;
    });

    try {
      final querySnapshot = await ownerRepository.fetchOwners(
        searchQuery: searchQuery.toLowerCase(),
        selectedFilter: selectedFilter,
        isFilterApplied: isFilterApplied,
        lastDocument: isLoadMore ? lastDocument : null,
      );

      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          lastDocument = querySnapshot.docs.last;
          if (!isLoadMore) {
            owners.clear();
          }
          owners.addAll(querySnapshot.docs);
        } else {
          hasMoreData = false;
        }
        isFetching = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load owners. Please try again.";
        isFetching = false;
      });
    }
  }

  //Serach bar with filter button
  void _showFilterBottomSheet() {
    String? tempFilter = selectedFilter; // Local copy for bottom sheet

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Filter Options",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  _buildFilterOption(setBottomSheetState, "Owner Name", () {
                    setBottomSheetState(() {
                      tempFilter = "Owner Name";
                    });
                  }, tempFilter),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150, // Increase button width
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedFilter = null;
                              isFilterApplied = false;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ), // Increase padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                16,
                              ), // Rounded corners
                            ),
                          ),
                          child: Text(
                            "Clear",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                      // SizedBox(width: 20), // Space between buttons
                      SizedBox(
                        width: 150, // Increase button width
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedFilter = tempFilter;
                              isFilterApplied = selectedFilter != null;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ), // Increase padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                16,
                              ), // Rounded corners
                            ),
                          ),
                          child: Text(
                            "Apply",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //selected filter option
  //Function to build filter options in the bottom sheet
  Widget _buildFilterOption(
    StateSetter setBottomSheetState,
    String filterName,
    VoidCallback onTap,
    String? tempFilter,
  ) {
    return ListTile(
      leading: const Icon(Icons.filter_alt),
      title: Text("Filter by $filterName"),
      onTap: onTap,
      trailing:
          tempFilter == filterName
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: CustomAppBar(
        title: 'Royal Finance Solutions',
        actionWidget: IconButton(
          icon: Image.asset("assets/images/ganesh_logo.jpg", height: 28),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        // padding: const EdgeInsetsDirectional.only(
        //   top: 10.0,
        //   start: 4.0,
        //   end: 4.0,
        // ),
        child: Column(
          children: [
            //--------------------/////////////------------------//

            // Search bar with filter button
            //Wrap the search bar with contaniner to give it a margin
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBarWithFilter(
                      controller: _searchController,
                      onFilterPressed: _showFilterBottomSheet,
                      hintText:
                          selectedFilter != null
                              ? 'Search by $selectedFilter'
                              : "Search...",
                      isFilterApplied: isFilterApplied,
                      onChanged: onSearchChanged,
                    ),
                  ),
                ],
              ),
            ),

            // SearchBarWithFilter(
            //   controller: _searchController,
            //   onFilterPressed: _showFilterBottomSheet,
            //   hintText:
            //       selectedFilter != null
            //           ? 'Search by $selectedFilter'
            //           : "Search...",
            //   isFilterApplied: isFilterApplied,
            //   onChanged: onSearchChanged,
            // ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),

            SizedBox(height: 5),

            //--------------------/////////////------------------//
            // List of owners (Placeholder for now)
            Expanded(
              child:
                  owners.isEmpty && !isFetching
                      ? Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? "No owners found. Add some owners to get started."
                              : "No matching owners found.",
                          textAlign: TextAlign.center,
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        // itemCount: owners.length + (isFetching ? 1 : 0),
                        itemCount:
                            owners.length + 1, // extra slot for loader/message
                        itemBuilder: (context, index) {
                          if (index == owners.length) {
                            // return Center(child: CircularProgressIndicator());
                            if (isFetching) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Center(
                                  child: Text(
                                    "No more owners to show",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }

                          var owner = owners[index];
                          var ownerName = owner['owner_name'] ?? 'Unknown';
                          // var capitalizedItemName = ownerName
                          //     .split(' ')
                          //     .map(
                          //       (word) =>
                          //           word[0].toUpperCase() +
                          //           word.substring(1).toLowerCase(),
                          //     )
                          //     .join(' ');
                          if (ownerName.length > 20) {
                            ownerName = ownerName.substring(0, 20) + "...";
                          }
                          try {
                            return GestureDetector(
                              // onTap: () async {
                              //   await Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder:
                              //           (context) => LoanHistoryPage(
                              //             createOwner: CreateOwnerModel(
                              //               ownerId: owner['owner_id'],
                              //               ownerName:
                              //                   owner['owner_name'],
                              //             ),
                              //           ),
                              //     ),
                              //   ).then((_) => fetchOwners());
                              // },
                              child: CustomListCard(
                                title: ownerName,
                                // bottomLeftText: "${owner['phone_number']}",
                                bottomLeftText: "${owner['phone_number']}",
                                topRightText: "#${owner['owner_id']}",
                                onEditTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => UpdateOwnerPage(
                                            createOwner: CreateOwnerModel(
                                              ownerId: owner['owner_id'],
                                              ownerName: owner['owner_name'],
                                              phoneNumber:
                                                  owner['phone_number'],
                                            ),
                                          ),
                                    ),
                                  ).then((_) => fetchOwners());
                                },
                                onDeleteTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => CustomDialogBox(
                                          title: "Delete Owner",
                                          content:
                                              "Are you sure you want to delete this owner?",
                                          onYesPressed: () async {
                                            Navigator.of(context).pop();
                                            await OwnerRepository().deleteOwner(
                                              owner['owner_id'],
                                            ); // your delete fn
                                            await fetchOwners(); // refresh list
                                          },
                                          onCancelPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop(); // Just close dialogs
                                          },
                                        ),
                                  );
                                },
                              ),
                            );
                          } catch (e) {
                            return ListTile(
                              title: Text("Error loading owner"),
                              subtitle: Text(e.toString()),
                            );
                          }
                        },
                      ),
            ),
            //--------------------/////////////------------------//
          ],
        ),
      ),

      //--------------------/////////////------------------//
      floatingActionButton: FloatingActionButton(
        splashColor: Colors.white70,
        backgroundColor: buttonColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddOwnerPage()),
          ).then((_) => fetchOwners());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
