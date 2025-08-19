// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loan_app/core/theme/app_theme.dart';

// class CustomListCard extends StatelessWidget {
//   final String title; // Top-left: Consignee Name
//   final String topRightText; // Top-right: Invoice ID
//   final String bottomLeftText; // Bottom-left: Total Bill
//   final String? bottomRightText; // Bottom-right: Created Date
//   // final VoidCallback? onDownloadTap; // Download icon tap action
//   final VoidCallback? onEditTap; // Edit icon tap action
//   final VoidCallback? onDeleteTap; // Delete icon tap action

//   const CustomListCard({
//     Key? key,
//     required this.title,
//     required this.topRightText,
//     required this.bottomLeftText,
//     this.bottomRightText,
//     // this.onDownloadTap,
//     this.onEditTap,
//     this.onDeleteTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: customerCardColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 2, left: 12, right: 12, top: 12),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 👤 Person icon
//             const Padding(
//               padding: EdgeInsets.only(right: 12, top: 16),
//               child: Icon(Icons.person, size: 30, color: Colors.blueGrey),
//             ),

//             // 🧾 Main content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🧷 Title + Customer ID
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Flexible(
//                         child: Text(
//                           title,
//                           style: GoogleFonts.raleway(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: cardTextColor,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Text(
//                         topRightText,
//                         style: GoogleFonts.lato(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: cardTextColor,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),

//                   // 🕓 Bottom row: total + icons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Left side: Total or detail
//                       Text(
//                         bottomLeftText,
//                         style: GoogleFonts.lato(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey[600],
//                         ),
//                       ),

//                       // Right side: Edit/Delete icons
//                       Row(
//                         children: [
//                           IconButton(
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                             icon: const Icon(
//                               Icons.edit,
//                               size: 20,
//                               color: Colors.blueAccent,
//                             ),
//                             onPressed: onEditTap, // Rename for clarity
//                           ),
//                           const SizedBox(width: 2),
//                           IconButton(
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                             icon: const Icon(
//                               Icons.delete,
//                               size: 20,
//                               color: Colors.red,
//                             ),
//                             onPressed: onDeleteTap, // Rename for clarity
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//============== Will use in next version ====================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class CustomListCard extends StatelessWidget {
  final String title;
  final String topRightText;
  final String bottomLeftText;
  final String? bottomRightText;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const CustomListCard({
    Key? key,
    required this.title,
    required this.topRightText,
    required this.bottomLeftText,
    this.bottomRightText,
    this.onEditTap,
    this.onDeleteTap,
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
            // 👤 Avatar Icon
            const Padding(
              padding: EdgeInsets.only(right: 10, top: 5),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFF2F4F6),
                child: Icon(Icons.person, size: 28, color: Colors.blueGrey),
              ),
            ),

            // 🧾 Card Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Title + ID
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
                      // Text(
                      //   topRightText,
                      //   style: GoogleFonts.lato(
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.grey[700],
                      //   ),
                      // ),
                    ],
                  ),

                  // const SizedBox(height: 1), // Reduced spacing
                  /// 🔻 Bottom Text + Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bottomLeftText,
                        style: GoogleFonts.lato(
                          fontSize: 12.5,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.edit_note_rounded,
                              size: 20,
                              color: Colors.indigo,
                            ),
                            onPressed: onEditTap,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                            onPressed: onDeleteTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//============== Will use in next version ====================