// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loan_app/core/theme/app_theme.dart';

// class CustomLoanCard extends StatelessWidget {
//   final String title;
//   final String loanId;
//   final String createdDate;
//   final String loanAmount;
//   final String dueDate;
//   final String ownerName;
//   final String? status;
//   final Color? color;
//   final VoidCallback? onDeleteTap;
//   final VoidCallback? onEditTap;

//   const CustomLoanCard({
//     Key? key,
//     required this.title,
//     required this.loanId,
//     required this.createdDate,
//     required this.loanAmount,
//     required this.dueDate,
//     required this.ownerName,
//     this.status,
//     this.color,
//     this.onDeleteTap,
//     this.onEditTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       color: customerCardColor,
//       shadowColor: Colors.black12,
//       // --------
//       // color: loanCardColor,
//       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔹 Row 1: Title + Loan ID
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: GoogleFonts.raleway(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: cardTextColor,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '#$loanId',
//                   style: GoogleFonts.lato(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: cardTextColor,
//                   ),
//                 ),
//               ],
//             ),

//             // const SizedBox(height: 4),

//             /// 🔹 Created Date
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 createdDate,
//                 style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
//               ),
//             ),

//             // const SizedBox(height: 4),

//             /// 🔹 Loan Amount + Due Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Loan Amount: $loanAmount',
//                   style: GoogleFonts.lato(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 Text(
//                   'Due Date: $dueDate',
//                   style: GoogleFonts.lato(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),

//             // const SizedBox(height: 4),

//             /// 🔹 Owner + Actions
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Text(
//                     'Owner: $ownerName',
//                     style: GoogleFonts.lato(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: cardTextColor,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 // Row(
//                 //   children: [
//                 //     IconButton(
//                 //       onPressed: onEditTap,
//                 //       icon: const Icon(
//                 //         Icons.edit,
//                 //         color: Colors.blueAccent,
//                 //         size: 20,
//                 //       ),
//                 //       constraints: const BoxConstraints(),
//                 //       padding: EdgeInsets.zero,
//                 //       tooltip: 'Edit',
//                 //     ),
//                 //     IconButton(
//                 //       visualDensity: VisualDensity.compact,
//                 //       icon: const Icon(
//                 //         Icons.delete_outline,
//                 //         size: 20,
//                 //         color: Colors.redAccent,
//                 //       ),
//                 //       onPressed: onDeleteTap,
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),

//             /// 🔹 Status Badge
//             if (status != null) ...[
//               // const SizedBox(height: 6),
//               StatusBadge(status: status!),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// 🔸 Reusable Status Badge
// class StatusBadge extends StatelessWidget {
//   final String status;

//   const StatusBadge({super.key, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     final statusMap = {
//       'active': {
//         'color': Colors.green.shade100,
//         'textColor': Colors.green.shade800,
//       },
//       'pending': {
//         'color': Colors.orange.shade100,
//         'textColor': Colors.orange.shade800,
//       },
//       'overdue': {
//         'color': Colors.red.shade100,
//         'textColor': Colors.red.shade800,
//       },
//       'closed': {
//         'color': Colors.grey.shade300,
//         'textColor': Colors.grey.shade800,
//       },
//     };

//     final badge =
//         statusMap[status.toLowerCase()] ??
//         {'color': Colors.blue.shade100, 'textColor': Colors.blue.shade800};

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: badge['color'],
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status[0].toUpperCase() + status.substring(1).toLowerCase(),
//         style: GoogleFonts.lato(
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//           color: badge['textColor'],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class CustomLoanCard extends StatelessWidget {
  final String title;
  final String loanId;
  final String createdDate;
  final String loanAmount;
  final String dueDate;
  final String ownerName;
  final String? status;
  final Color? color;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onEditTap;

  const CustomLoanCard({
    Key? key,
    required this.title,
    required this.loanId,
    required this.createdDate,
    required this.loanAmount,
    required this.dueDate,
    required this.ownerName,
    this.status,
    this.color,
    this.onDeleteTap,
    this.onEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: customerCardColor,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Avatar Icon (Loan Icon)
            const Padding(
              padding: EdgeInsets.only(right: 10, top: 5),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFF2F4F6),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 26,
                  color: Colors.blueGrey,
                ),
              ),
            ),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + Loan ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.raleway(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: cardTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        createdDate,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      // Text(
                      //   '#$loanId',
                      //   style: GoogleFonts.lato(
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.grey[700],
                      //   ),
                      // ),
                    ],
                  ),

                  /// Created Date
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Text(
                  //     createdDate,
                  //     style: GoogleFonts.lato(
                  //       fontSize: 12,
                  //       color: Colors.grey[600],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 4),

                  /// Loan Amount + Due Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // parse the loan amount to integer no decimal with rupee symbol
                        'Loan Amount: ₹${double.parse(loanAmount).toStringAsFixed(0)}',
                        // 'Loan Amount: $loanAmount',
                        style: GoogleFonts.lato(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                        ),
                      ),
                      // Text(
                      //   'Due Date: $dueDate',
                      //   style: GoogleFonts.lato(
                      //     fontSize: 12.5,
                      //     color: Colors.grey[600],
                      //   ),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// Owner + Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Owner: $ownerName',
                          style: GoogleFonts.lato(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: cardTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Due: $dueDate',
                        style: GoogleFonts.lato(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     IconButton(
                      //       visualDensity: VisualDensity.compact,
                      //       icon: const Icon(
                      //         Icons.edit_note_rounded,
                      //         size: 20,
                      //         color: Colors.indigo,
                      //       ),
                      //       onPressed: onEditTap,
                      //     ),
                      //     const SizedBox(width: 4),
                      //     IconButton(
                      //       visualDensity: VisualDensity.compact,
                      //       icon: const Icon(
                      //         Icons.delete_outline,
                      //         size: 20,
                      //         color: Colors.redAccent,
                      //       ),
                      //       onPressed: onDeleteTap,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),

                  /// Status Badge
                  if (status != null) ...[
                    const SizedBox(height: 4),
                    StatusBadge(status: status!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusMap = {
      'active': {
        'color': Colors.green.shade100,
        'textColor': Colors.green.shade800,
      },
      'pending': {
        'color': Colors.orange.shade100,
        'textColor': Colors.orange.shade800,
      },
      'overdue': {
        'color': Colors.red.shade100,
        'textColor': Colors.red.shade800,
      },
      'closed': {
        'color': Colors.grey.shade300,
        'textColor': Colors.grey.shade800,
      },
    };

    final badge =
        statusMap[status.toLowerCase()] ??
        {'color': Colors.blue.shade100, 'textColor': Colors.blue.shade800};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badge['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1).toLowerCase(),
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badge['textColor'],
        ),
      ),
    );
  }
}
