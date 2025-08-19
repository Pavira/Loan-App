import 'package:contacts_service_plus/contacts_service_plus.dart';
import 'package:flutter/material.dart';
import 'package:loan_app/features/customer/presentation/add_customer_page.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactSelectorBottomSheet extends StatefulWidget {
  final VoidCallback onAddCustomer;

  const ContactSelectorBottomSheet({super.key, required this.onAddCustomer});

  @override
  State<ContactSelectorBottomSheet> createState() =>
      _ContactSelectorBottomSheetState();
}

class _ContactSelectorBottomSheetState
    extends State<ContactSelectorBottomSheet> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts(
        withThumbnails: false,
      );
      setState(() {
        _contacts = contacts.toList();
        _filteredContacts = _contacts;
      });
    } else {
      // You could show a message if permission is denied
      setState(() => _contacts = []);
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredContacts =
          _contacts
              .where(
                (c) => (c.displayName ?? '').toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder:
          (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: _filterContacts,
                  decoration: const InputDecoration(
                    labelText: 'Search Customer Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  // onTap: widget.onAddCustomer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCustomerPage(),
                      ),
                    ).then((_) {
                      Navigator.pop(context); // Close bottom sheet
                      widget
                          .onAddCustomer(); // 🔁 This triggers fetchCustomers() from parent
                    });
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Add New Customer',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 20),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: _filteredContacts.length,
                    itemBuilder: (_, index) {
                      final contact = _filteredContacts[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(contact.displayName ?? 'Unnamed'),
                        subtitle:
                            contact.phones != null && contact.phones!.isNotEmpty
                                ? Text(contact.phones!.first.value ?? '')
                                : null,
                        onTap: () {
                          // Return the selected contact or process it
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddCustomerPage(
                                    contactName:
                                        contact.displayName ?? 'Unnamed',
                                    contactPhoneNumber:
                                        contact.phones!.first.value ?? '',
                                  ),
                            ),
                          ).then((_) {
                            Navigator.pop(context); // Close bottom sheet
                            widget
                                .onAddCustomer(); // 🔁 This triggers fetchCustomers() from parent
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
