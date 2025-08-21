import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/customer/data/customer_model.dart';
import 'package:loan_app/features/customer/presentation/add_customer_page.dart';
import 'package:loan_app/features/customer/data/customer_repository.dart';
import 'package:loan_app/features/customer/presentation/update_customer_page.dart';
import 'package:loan_app/features/loan/presentation/loan_history_page.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/contact_selector_bottom_sheet.dart';
import 'package:loan_app/widgets/list_card.dart';
import 'package:loan_app/widgets/rain_drop_animation.dart';
import 'package:loan_app/widgets/search_bar.dart';

class ViewCustomerPage extends StatefulWidget {
  @override
  ViewCustomerPageState createState() => ViewCustomerPageState();
}

class ViewCustomerPageState extends State<ViewCustomerPage> {
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final CustomerRepository customerRepository = CustomerRepository();

  List<DocumentSnapshot> customers = [];
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
    fetchCustomers();
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
      fetchCustomers(isLoadMore: true);
    }
  }

  // Handle search input
  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      // print('Search query: $searchQuery');
      lastDocument = null;
      customers.clear(); // Reset list
      hasMoreData = true;
    });
    fetchCustomers();
  }

  /// Fetch initial customers or more customers when paginating
  Future<void> fetchCustomers({bool isLoadMore = false}) async {
    if (isFetching || (!hasMoreData && isLoadMore)) return;

    setState(() {
      isFetching = true;
      errorMessage = null;
    });

    try {
      final querySnapshot = await customerRepository.fetchCustomers(
        searchQuery: searchQuery.toLowerCase(),
        selectedFilter: selectedFilter,
        isFilterApplied: isFilterApplied,
        lastDocument: isLoadMore ? lastDocument : null,
      );

      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          lastDocument = querySnapshot.docs.last;
          if (!isLoadMore) {
            customers.clear();
          }
          customers.addAll(querySnapshot.docs);
        } else {
          hasMoreData = false;
        }
        isFetching = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load customers. Please try again.";
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

                  _buildFilterOption(setBottomSheetState, "Customer Name", () {
                    setBottomSheetState(() {
                      tempFilter = "Customer Name";
                    });
                  }, tempFilter),
                  _buildFilterOption(setBottomSheetState, "Phone Number", () {
                    setBottomSheetState(() {
                      tempFilter = "Phone Number";
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
          onPressed: () {
            // Trigger raindrop animation
            RainDropManager.showRain(
              context,
              dropWidget: Image.asset(
                "assets/images/ganesh_logo.png",
                height: 20,
              ),
              dropCount: 40,
            );
          },
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
            // List of customers (Placeholder for now)
            Expanded(
              child:
                  customers.isEmpty && !isFetching
                      ? Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? "No customers found. Add some customers to get started."
                              : "No matching customers found.",
                          textAlign: TextAlign.center,
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        // itemCount: customers.length + (isFetching ? 1 : 0),
                        itemCount:
                            customers.length +
                            1, // extra slot for loader/message
                        itemBuilder: (context, index) {
                          if (index == customers.length) {
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
                                    "No more customers to show",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }

                          var customer = customers[index];
                          var customerName =
                              customer['customer_name'] ?? 'Unknown';
                          // var capitalizedItemName = customerName
                          //     .split(' ')
                          //     .map(
                          //       (word) =>
                          //           word[0].toUpperCase() +
                          //           word.substring(1).toLowerCase(),
                          //     )
                          //     .join(' ');
                          if (customerName.length > 20) {
                            customerName =
                                customerName.substring(0, 20) + "...";
                          }
                          try {
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => LoanHistoryPage(
                                          createCustomer: CreateCustomerModel(
                                            customerId: customer['customer_id'],
                                            customerName:
                                                customer['customer_name'],
                                            phoneNumber:
                                                customer['phone_number'],
                                            alternatePhoneNumber:
                                                customer['alternate_phone_number'] ??
                                                '',
                                            gender: customer['gender'],
                                            address: customer['address'],
                                          ),
                                        ),
                                  ),
                                ).then((_) => fetchCustomers());
                              },
                              child: CustomListCard(
                                title: customerName,
                                bottomLeftText: "${customer['phone_number']}",
                                topRightText: "#${customer['customer_id']}",
                                onEditTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => UpdateCustomerPage(
                                            createCustomer: CreateCustomerModel(
                                              customerId:
                                                  customer['customer_id'],
                                              customerName:
                                                  customer['customer_name'],
                                              phoneNumber:
                                                  customer['phone_number'],
                                              alternatePhoneNumber:
                                                  customer['alternate_phone_number'] ??
                                                  '',
                                              gender: customer['gender'],
                                              address: customer['address'],
                                            ),
                                          ),
                                    ),
                                  ).then((_) => fetchCustomers());
                                },
                              ),
                            );
                          } catch (e) {
                            return ListTile(
                              title: Text("Error loading Customer"),
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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),

            builder:
                (_) => ContactSelectorBottomSheet(
                  onAddCustomer: () {
                    fetchCustomers(); // ✅ Will be called after customer is added
                  },
                ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
