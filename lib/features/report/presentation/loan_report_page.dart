import 'package:flutter/material.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/loan/data/loan_model.dart';
import 'package:loan_app/features/loan/data/loan_repository.dart';
import 'package:loan_app/features/loan/data/owner_model.dart';
import 'package:loan_app/features/report/data/report_repository.dart';
import 'package:loan_app/widgets/animated_dynamic_dropdown.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/button.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';

class LoanPage extends StatefulWidget {
  @override
  _LoanPageState createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  Owner? selectedOwner;
  DateTime? selectedMonth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  List<DateTime> generateMonthList({
    int pastMonths = 12,
    int futureMonths = 12,
  }) {
    final now = DateTime.now();
    return List.generate(pastMonths + futureMonths + 1, (index) {
      final month = DateTime(now.year, now.month - pastMonths + index);
      return month;
    });
  }

  String formatMonthYear(DateTime date) {
    return "${_monthNames[date.month - 1]} ${date.year}";
  }

  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String getMonthDocId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  // ----------------Storage Permission Function------------------
  // Future<bool> requestStoragePermission() async {
  //   final status = await Permission.storage.request();
  //   return status.isGranted;
  // }

  // Future<bool> requestStoragePermission() async {
  //   if (Platform.isAndroid) {
  //     // For Android 11+ (SDK 30+)
  //     final manageExternalStorage =
  //         await Permission.manageExternalStorage.status;
  //     final storagePermission = await Permission.storage.status;

  //     if (!manageExternalStorage.isGranted || !storagePermission.isGranted) {
  //       final result =
  //           await [
  //             Permission.manageExternalStorage,
  //             Permission.storage,
  //           ].request();

  //       final granted =
  //           result[Permission.manageExternalStorage]?.isGranted == true &&
  //           result[Permission.storage]?.isGranted == true;

  //       if (!granted) {
  //         print('❌ Storage permission denied');
  //         return false;
  //       }
  //     }

  //     return true;
  //   }
  //   return true;
  // }

  // ----------------Excel Export Function------------------
  Future<void> exportLoanReport(
    String ownerName,
    String? selectedMonth,
    List<LoanReportModel> loanData,
  ) async {
    // if (!await requestStoragePermission()) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Storage permission is required to save Excel')),
    //   );
    //   return;
    // }

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Report Headings
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("H1"));
    sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(
      "Report for Month: ${selectedMonth ?? ''}",
    );

    sheet.merge(CellIndex.indexByString("A2"), CellIndex.indexByString("H2"));
    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue(
      "Owner: $ownerName",
    );

    // Column Headers
    sheet.appendRow([
      TextCellValue('S.No.'),
      TextCellValue('Loan ID'),
      TextCellValue('Customer Name'),
      TextCellValue('Phone Number'),
      TextCellValue('Re-payment Amount'),
      TextCellValue('Is Paid'),
      TextCellValue('Pending Amount'),
      TextCellValue('Total Loan Amount'),
    ]);

    // Loan Data Rows
    for (int i = 0; i < loanData.length; i++) {
      final item = loanData[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(item.loanId),
        TextCellValue(item.customerName),
        TextCellValue(item.customerPhone),
        DoubleCellValue(item.repaymentAmount),
        TextCellValue(item.isPaid ? 'Paid' : 'Pending'),
        DoubleCellValue(item.totalPendingAmount),
        DoubleCellValue(item.totalLoanAmount),
      ]);
    }

    // Save File to Downloads
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final fileName = 'Loan_Report_${selectedMonth ?? ''}_$ownerName.xlsx'
        .replaceAll(' ', '_');
    final filePath = '${downloadsDir.path}/$fileName';

    final file =
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.encode()!);

    print("✅ Excel saved to: $filePath");

    await OpenFile.open(filePath);
  }
  // ----------------Excel Export Function End------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: CustomAppBar(title: 'Loan Report', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownSearchWidget<DateTime>(
                    label: "Select Month*",
                    selectedItem: selectedMonth,
                    asyncItemsFetcher:
                        (_) async =>
                            generateMonthList(pastMonths: 12, futureMonths: 12),
                    itemAsString: (date) => formatMonthYear(date),
                    onChanged: (date) {
                      setState(() {
                        selectedMonth = date;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownSearchWidget<Owner>(
                    label: "Select Owner*",
                    selectedItem: selectedOwner,
                    asyncItemsFetcher: (filter) async {
                      return await LoanRepository().fetchOwners();
                    },
                    itemAsString: (owner) => owner.name,
                    onChanged: (Owner? owner) {
                      setState(() {
                        selectedOwner = owner;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : CustomButton(
                        text: "Generate Report",
                        onPressed: () async {
                          if (selectedOwner == null || selectedMonth == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please select both month and owner",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            String ownerName = selectedOwner!.name;
                            String monthDocId = getMonthDocId(
                              selectedMonth!,
                            ); // "2025-10"
                            String selectedMonthReport = formatMonthYear(
                              selectedMonth!,
                            ); // "October 2025"

                            final loanData = await ReportRepository()
                                .fetchLoanReport(
                                  monthDocId: monthDocId,
                                  ownerName: ownerName,
                                );

                            print("Loan Data: $loanData");
                            if (loanData.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("No data found")),
                              );
                              return;
                            }

                            await exportLoanReport(
                              ownerName,
                              selectedMonthReport,
                              loanData,
                            );
                          } catch (e) {
                            print("❌ Error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to export report"),
                              ),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
