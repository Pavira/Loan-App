// loan_details_page.dart

import 'package:flutter/material.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/loan/data/owner_model.dart';
import 'package:loan_app/features/owner/presentation/view_owner_page.dart';
import 'package:loan_app/features/report/presentation/loan_report_page.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/custom_snackbar.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoading = false;

  // Controls animation visibility
  bool showContent = false;

  @override
  void initState() {
    super.initState();
    // Delay to show animation after build
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        showContent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: CustomAppBar(
        title: 'App Settings',
        centerTitle: true,
        actionWidget: IconButton(
          icon: Image.asset("assets/images/ganesh_logo.jpg", height: 28),
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image with opacity
            Opacity(
              opacity: 0.1, // Adjust this value (0.0 to 1.0)
              child: Image.asset(
                'assets/images/logo.jpeg', // Replace with your image path
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAnimatedCard(child: _buildMaster(context)),
                      _buildAnimatedCard(child: _buildReportDetails(context)),
                      _buildAnimatedCard(child: _buildAppDetails()),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaster(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masters',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Configuration', style: TextStyle(fontSize: 13)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              showCustomSnackbar(
                context,
                "Switch to paid plan to view customer report",
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => LoanPage()),
              // );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Owner Details', style: TextStyle(fontSize: 13)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewOwnerPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Wrap any child with AnimatedContainer for smooth slide + fade-in effect
  Widget _buildAnimatedCard({required Widget child}) {
    return AnimatedOpacity(
      opacity: showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        transform:
            showContent
                ? Matrix4.identity()
                : Matrix4.translationValues(0, 30, 0),
        child: child,
      ),
    );
  }

  Widget _buildReportDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Customer Report',
              style: TextStyle(fontSize: 13),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              showCustomSnackbar(
                context,
                "Switch to paid plan to view customer report",
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => LoanPage()),
              // );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Monthly Loan Report',
              style: TextStyle(fontSize: 13),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoanPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'App Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 12),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Version: 1.0.0', style: TextStyle(fontSize: 12)),
          ),
          // Text('Terms and Conditions', style: TextStyle(fontSize: 12)),
          // SizedBox(height: 8),
          // Text('Version: 1.0.0', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
//   Widget ReportDetails() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Reports',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//           ),
//           const Divider(),
//           ListTile(
//             title: const Text(
//               'Customer Report',
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//             ),
//             onTap: () {
//               // Navigate to Customer Report
//             },
//           ),
//           ListTile(
//             title: const Text(
//               'Loan Report',
//               style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//             ),
//             onTap: () {
//               // Navigate to Loan Report
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget AppDetails() {
//   return AnimatedContainer(
//     // padding: const EdgeInsets.all(12),
//     // margin: const EdgeInsets.only(bottom: 12),
//     // decoration: BoxDecoration(
//     //   color: Colors.white,
//     //   borderRadius: BorderRadius.circular(8),
//     //   boxShadow: const [
//     //     BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//     //   ],
//     // ),
//     duration: Duration(milliseconds: 500),
//     curve: Curves.easeInOut,
//     padding: const EdgeInsets.all(12),
//     margin: const EdgeInsets.only(bottom: 12),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: const [
//         BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'App Details',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//         ),
//         const Divider(),
//         const Text('Terms and Conditions', style: TextStyle(fontSize: 12)),
//         SizedBox(height: 8),
//         const Text('Version: 1.0.0', style: TextStyle(fontSize: 12)),
//       ],
//     ),
//   );
// }
