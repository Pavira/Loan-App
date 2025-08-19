import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class CustomLoanHistoryCard extends StatelessWidget {
  final String loanId;
  final String createdDate;
  final String loanAmount;
  final String dueDate;
  final String ownerName;
  final String? status;
  final Color? color;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onEditTap;

  const CustomLoanHistoryCard({
    Key? key,
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
      color: loanCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Row 1: Title + Loan ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '#$loanId',
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: cardTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  createdDate,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cardTextColor,
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 4),

            /// 🔹 Created Date
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: Text(
            //     createdDate,
            //     style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600]),
            //   ),
            // ),
            const SizedBox(height: 4),

            /// 🔹 Loan Amount + Due Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loan Amount: $loanAmount',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Due Date: $dueDate',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            /// 🔹 Owner + Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Owner: $ownerName',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cardTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Row(
                //   children: [
                //     IconButton(
                //       onPressed: onEditTap,
                //       icon: const Icon(
                //         Icons.edit,
                //         color: Colors.blueAccent,
                //         size: 20,
                //       ),
                //       constraints: const BoxConstraints(),
                //       padding: EdgeInsets.zero,
                //       tooltip: 'Edit',
                //     ),
                //     IconButton(
                //       onPressed: onDeleteTap,
                //       icon: const Icon(
                //         Icons.delete,
                //         color: Colors.red,
                //         size: 20,
                //       ),
                //       constraints: const BoxConstraints(),
                //       padding: EdgeInsets.zero,
                //       tooltip: 'Delete',
                //     ),
                //   ],
                // ),
              ],
            ),

            /// 🔹 Status Badge
            if (status != null) ...[
              // const SizedBox(height: 6),
              StatusBadge(status: status!),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🔸 Reusable Status Badge
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
