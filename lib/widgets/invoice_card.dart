import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInvoiceCard extends StatelessWidget {
  final String title; // Consignee Name
  final String topRightText; // Invoice ID
  final String createdDate; // Created Date
  final String purchaseOrderNo; // PO No
  final String purchaseDate; // PO Date
  final String totalBill; // Total Bill
  final Color? color;
  final VoidCallback? onDownloadTap;
  final VoidCallback? onStatusChangesTap;

  const CustomInvoiceCard({
    Key? key,
    required this.title,
    required this.topRightText,
    required this.createdDate,
    required this.purchaseOrderNo,
    required this.purchaseDate,
    required this.totalBill,
    this.color,
    this.onDownloadTap,
    this.onStatusChangesTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Consignee Name + Invoice ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  topRightText,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Row 2: Created Date (Right aligned)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                createdDate,
                style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[700]),
              ),
            ),

            const SizedBox(height: 8),

            // Row 3: PO No. + PO Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchaseOrderNo,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  purchaseDate,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 4: Total Bill + Download Icon + deleter Icon
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalBill,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(), // Push buttons to the right
                if (onDownloadTap != null)
                  IconButton(
                    onPressed: onDownloadTap,
                    icon: const Icon(Icons.download, color: Colors.blueAccent),
                  ),
                if (onStatusChangesTap != null)
                  IconButton(
                    onPressed: onStatusChangesTap,
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
