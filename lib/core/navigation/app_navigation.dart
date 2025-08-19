import 'package:flutter/material.dart';
import 'package:loan_app/features/loan/presentation/view_loan_page.dart';
import 'package:loan_app/features/settings/presentation/settings.dart';
// import 'package:loan_app/features/report/presentation/reports_page.dart';
import '../../features/home/presentation/home_page.dart';
// import '../../features/invoice/presentation/invoice_page.dart';
import '../../features/customer/presentation/view_customer_page.dart';
// import '../../features/consignee/presentation/consignee_page.dart';
// import '../../features/menu/presentation/menu_page.dart';
import '../../widgets/bottom_nav_bar.dart';
// import '../../widgets/overlay_button.dart';

class AppNavigation extends StatefulWidget {
  final int initialIndex;

  const AppNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _AppNavigationState createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ViewCustomerPage(),
    ViewLoanPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
