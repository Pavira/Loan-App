// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/home/data/home_repository.dart';
import 'package:loan_app/features/loan/data/loan_repository.dart';
import 'package:loan_app/features/loan/data/owner_model.dart';
import 'package:loan_app/widgets/animated_dynamic_dropdown.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/loan_home_card.dart';
import 'package:loan_app/widgets/rain_drop_animation.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Owner? selectedOwner;
  Future<Map<String, int>>? _countsFuture;
  bool _isFirstBuild = true;
  // late Future<List<Owner>> _ownerNames;
  Future<List<Map<String, dynamic>>>? _loanDataFuture;
  // Future<List<LoanReportModel>>? _loanDataFuture;

  @override
  void initState() {
    super.initState();
    requestContactPermission();

    _initializeOwnerAndData();
  }

  void _initializeOwnerAndData() async {
    final owners = await LoanRepository().fetchOwners();
    if (owners.isNotEmpty) {
      setState(() {
        selectedOwner = owners.first;
        _loanDataFuture = HomeRepository().fetchPresentMonthLoanData(
          ownerName: selectedOwner!.name,
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _countsFuture = HomeRepository().fetchCounts();
      _isFirstBuild = false;
    }
  }

  Future<void> requestContactPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  Future<void> _refreshCounts() async {
    setState(() {
      _countsFuture = HomeRepository().fetchCounts();
      _loadLoanData();
    });
  }

  void _loadLoanData() {
    if (selectedOwner != null) {
      _loanDataFuture = HomeRepository().fetchPresentMonthLoanData(
        ownerName: selectedOwner!.name,
      );
    } else {
      _loanDataFuture = Future.value([]);
    }
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCounts,
          child: FutureBuilder<Map<String, int>>(
            future: _countsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading counts'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              }

              final counts = snapshot.data!;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// 🔹 Grid of 4 cards
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio:
                          1.6, // Adjust this for width/height ratio
                      children: [
                        HomeCardWidget(
                          title: "Total Loans",
                          content: counts['loan_count'].toString(),
                          color: [Colors.green.shade100, Colors.green.shade800],
                          icon: Icons.account_balance,
                        ),
                        HomeCardWidget(
                          title: "Total Customers",
                          content: counts['customer_count'].toString(),
                          color: [Colors.blue.shade100, Colors.blue.shade800],
                          icon: Icons.group,
                        ),
                        HomeCardWidget(
                          title: "Active Loans",
                          content: counts['active_loans'].toString(),
                          color: [
                            Colors.orange.shade100,
                            Colors.orange.shade800,
                          ],
                          icon: Icons.timer,
                        ),
                        HomeCardWidget(
                          title: "Closed Loans",
                          content: counts['closed_loans'].toString(),
                          color: [Colors.red.shade100, Colors.red.shade800],
                          icon: Icons.lock,
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    /// 🔸 Loan Summary Table
                    const Text(
                      'Loan Summary Table',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // -----------ACTIVE LOANS TABLE----------------------
                    activeLoansTable(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget activeLoansTable() {
    final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Header Row: Month + Dropdown
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  currentMonth,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: DropdownSearchWidget<Owner>(
                  label: "Select Owner*",
                  selectedItem: selectedOwner,
                  asyncItemsFetcher: (filter) async {
                    return await LoanRepository().fetchOwners();
                  },
                  itemAsString: (owner) => owner.name,
                  onChanged: (Owner? owner) {
                    setState(() {
                      selectedOwner = owner;
                      _loadLoanData();
                    });
                  },
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          /// Loan Table
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loanDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Text('Error loading loan data');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No data available for this owner');
              }

              final data = snapshot.data!;
              final totalToCollect = data
                  .where(
                    (item) => item['status'] == false,
                  ) // ✅ Only unpaid loans
                  .fold<num>(
                    0,
                    (sum, item) => sum + (item['re-payment_amount'] ?? 0),
                  );

              return Column(
                children: [
                  /// Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 6,
                    ),
                    color: Colors.grey.shade100,
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Name",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Status",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Re-Pay",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Pending",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Total",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Table Rows
                  ...data.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 6.0,
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              (entry['customer_name'] ?? '').toString().length >
                                      5
                                  ? '${(entry['customer_name'] ?? '').toString().substring(0, 5)}...'
                                  : entry['customer_name'] ?? '',
                              style: const TextStyle(fontSize: 11),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              // Give code status is true, show "Paid" and colour green, else "Pending" and red
                              entry['status'] == true ? "Paid" : "Pending",
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    entry['status'] == true
                                        ? Colors.green
                                        : Colors.red,
                              ),

                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              style: TextStyle(fontSize: 11),
                              "₹${entry['repayment_amount'] ?? 0}",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              style: TextStyle(fontSize: 11),
                              "₹${entry['total_pending_amount'] ?? 0}",
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              style: TextStyle(fontSize: 11),
                              "₹${entry['total_loan_amount'] ?? 0}",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ==============================================
                  const Divider(height: 20),

                  /// Total Summary
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total amount to collect - ₹$totalToCollect",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        // color: Colors.deepPurple,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

 /// Additional List (if needed below table)
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   itemCount: filteredData.length,
              //   itemBuilder: (context, index) {
              //     final entry = filteredData[index];
              //     return ListTile(
              //       title: Text(entry['name']),
              //       subtitle: Text(
              //         "Repaid ₹${entry['rePay']}, Pending ₹${entry['pending']}",
              //       ),
              //       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              //       onTap: () {
              //         // Navigate to loan detail
              //       },
              //     );
              //   },
              // ),