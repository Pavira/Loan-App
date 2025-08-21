import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/customer/data/customer_repository.dart';
import 'package:loan_app/features/loan/data/loan_model.dart';
import 'package:loan_app/features/loan/data/loan_repository.dart';
import 'package:loan_app/features/loan/presentation/add_loan_page.dart';
import 'package:loan_app/features/loan/presentation/loan_details_page.dart';
// import 'package:loan_app/features/loan/presentation/update_loan_page.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/loan_card.dart';
import 'package:loan_app/widgets/rain_drop_animation.dart';
import 'package:loan_app/widgets/search_bar.dart';

class ViewLoanPage extends StatefulWidget {
  @override
  ViewLoanPageState createState() => ViewLoanPageState();
}

class ViewLoanPageState extends State<ViewLoanPage> {
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final CustomerRepository customerRepository = CustomerRepository();

  List<DocumentSnapshot> loans = [];
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
    loanDetails();
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
      loanDetails(isLoadMore: true);
    }
  }

  // Handle search input
  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      lastDocument = null;
      loans.clear(); // Reset list
      hasMoreData = true;
    });
    loanDetails();
  }

  /// Fetch initial loans or more loans when paginating
  Future<void> loanDetails({bool isLoadMore = false}) async {
    if (isFetching || (!hasMoreData && isLoadMore)) return;

    setState(() {
      isFetching = true;
      errorMessage = null;
    });

    try {
      LoanRepository loanRepository = LoanRepository();
      final querySnapshot = await loanRepository.fetchLoanDetails(
        searchQuery: searchQuery.toLowerCase(),
        selectedFilter: selectedFilter,
        isFilterApplied: isFilterApplied,
        lastDocument: isLoadMore ? lastDocument : null,
      );

      setState(() {
        if (querySnapshot.docs.isNotEmpty) {
          lastDocument = querySnapshot.docs.last;
          if (!isLoadMore) {
            loans.clear();
          }
          loans.addAll(querySnapshot.docs);
        } else {
          hasMoreData = false;
        }
        isFetching = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load loans. Please try again.";
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
            // List of loans (Placeholder for now)
            Expanded(
              child:
                  loans.isEmpty && !isFetching
                      ? Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? "No loans found. Add some loans to get started."
                              : "No matching loans found.",
                          textAlign: TextAlign.center,
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        // itemCount: loans.length + (isFetching ? 1 : 0),
                        itemCount:
                            loans.length + 1, // extra slot for loader/message
                        itemBuilder: (context, index) {
                          if (index == loans.length) {
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
                                    "No more loans to show",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }

                          var loan = loans[index];
                          var customerName = loan['customer_name'] ?? 'Unknown';
                          // var capitalizedItemName = customerName
                          //     .split(' ')
                          //     .map(
                          //       (word) =>
                          //           word[0].toUpperCase() +
                          //           word.substring(1).toLowerCase(),
                          //     )
                          //     .join(' ');
                          if (customerName.length > 15) {
                            customerName =
                                customerName.substring(0, 15) + "...";
                          }
                          try {
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => LoanDetailsPage(
                                          createLoanModel: CreateLoanModel(
                                            loanId: loan['loan_id'] ?? '',
                                            customerId:
                                                loan['customer_id'] ?? '',
                                            ownerId: loan['owner_id'] ?? '',
                                            customerName:
                                                loan['customer_name'] ?? '',
                                            ownerName: loan['owner_name'] ?? '',
                                            loanAmount:
                                                double.tryParse(
                                                  loan['loan_amount']
                                                          ?.toString() ??
                                                      '0',
                                                ) ??
                                                0,
                                            dueDate:
                                                loan['due_date'] != null
                                                    ? (loan['due_date']
                                                            as Timestamp)
                                                        .toDate()
                                                    : null,
                                            calculatedMonthlyPayment:
                                                loan['calculated_monthly_payment'],
                                            interestRate: loan['interest_rate'],
                                            loanDuration: loan['loan_duration'],
                                            status: loan['status'] ?? 'active',
                                          ),
                                        ),
                                  ),
                                );
                                loanDetails();
                              },
                              child: CustomLoanCard(
                                title: customerName,
                                createdDate:
                                    loan['created_date'] != null
                                        ? DateFormat('dd-MMM-yy').format(
                                          (loan['created_date'] as Timestamp)
                                              .toDate(),
                                        )
                                        : 'Unknown',
                                loanId: loan['loan_id'] ?? 'Unknown',
                                loanAmount:
                                    loan['loan_amount']?.toString() ?? '0',
                                dueDate:
                                    loan['due_date'] != null
                                        ? DateFormat('dd-MMM-yy').format(
                                          (loan['due_date'] as Timestamp)
                                              .toDate(),
                                        )
                                        : 'Unknown',
                                ownerName: loan['owner_name'] ?? 'Unknown',
                                status: loan['status'] ?? 'active',
                                onEditTap: () async {
                                  // await Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder:
                                  //         (context) => UpdateLoanPage(
                                  //           createLoanModel: CreateLoanModel(
                                  //             loanId: loan['loan_id'] ?? '',
                                  //             customerId:
                                  //                 loan['customer_id'] ?? '',
                                  //             ownerId: loan['owner_id'] ?? '',

                                  //             customerName:
                                  //                 loan['customer_name'] ?? '',
                                  //             ownerName:
                                  //                 loan['owner_name'] ?? '',
                                  //             loanAmount:
                                  //                 double.tryParse(
                                  //                   loan['loan_amount']
                                  //                           ?.toString() ??
                                  //                       '0',
                                  //                 ) ??
                                  //                 0.0,
                                  //             status:
                                  //                 loan['status'] ?? 'active',

                                  //             // Convert  due_date to  DateTime? _selectedDueDate;
                                  //             dueDate:
                                  //                 loan['due_date'] != null
                                  //                     ? (loan['due_date']
                                  //                             as Timestamp)
                                  //                         .toDate()
                                  //                     : null,

                                  //             calculatedMonthlyPayment:
                                  //                 loan['calculated_monthly_payment'],
                                  //             interestRate:
                                  //                 loan['interest_rate'],
                                  //             loanDuration:
                                  //                 loan['loan_duration'],
                                  //           ),
                                  //         ),
                                  //   ),
                                  // ).then((_) => loanDetails());
                                },
                              ),
                            );
                          } catch (e) {
                            return ListTile(
                              title: Text("Error loading Loans"),
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
            MaterialPageRoute(builder: (_) => AddLoanPage()),
          ).then((_) => loanDetails());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
