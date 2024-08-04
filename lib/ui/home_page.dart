import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:contacts/helpers/contact_helper.dart';

import 'contact_page.dart';

enum OrderOptions {
  aToZ,
  zToA,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];
  OrderOptions orderOptions = OrderOptions.aToZ;

  @override
  void initState() {
    super.initState();
    _getAllContacts(orderOptions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            iconColor: Colors.white,
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.aToZ,
                child: Text('Order from A-Z'),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.zToA,
                child: Text('Order from Z-A'),
              ),
            ],
            onSelected: (OrderOptions result) {
              setState(() {
                orderOptions = result;
                _getAllContacts(orderOptions);
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage(order: orderOptions);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: contacts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'You don\'t have any contacts yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final item = contacts[index];

                return GestureDetector(
                  onTap: () {
                    _showOptions(context, index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            SizedBox.square(
                              dimension: 80.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40.0),
                                child: item.img.isNotEmpty
                                    ? Image.file(
                                        File(item.img),
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person_rounded,
                                        size: 80.0,
                                        color: Colors.grey[700],
                                      ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                height: 80.0,
                                width: 1.0,
                                color: Colors.grey[300],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item.email,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    item.phone,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    item.id.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showOptions(BuildContext context, int index) {
    final phone = contacts[index].phone;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (phone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextButton(
                        child: const Text(
                          'Call',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0,
                          ),
                        ),
                        onPressed: () {
                          launchUrlString('tel:$phone');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextButton(
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(
                          contact: contacts[index],
                          order: orderOptions,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        helper.deleteContact(contacts[index].id);

                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactPage({
    Contact? contact,
    required OrderOptions order,
  }) async {
    final Contact? recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
        ),
      ),
    );

    if (recContact != null) {
      await helper.updateOrCreateContact(recContact);
      _getAllContacts(order);
    }
  }

  Future<void> _getAllContacts(
    OrderOptions order,
  ) async {
    final list = await helper.getAllContacts(order);
    setState(() {
      contacts = list as List<Contact>;
    });
  }
}
