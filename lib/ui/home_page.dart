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
          'Contatos',
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
                child: Text('Ordenar de A-Z'),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.zToA,
                child: Text('Ordenar de Z-A'),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final item = contacts[index];

          return GestureDetector(
            onTap: () {
              _showOptions(context, index);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    SizedBox.square(
                      dimension: 80.0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: item.img.isNotEmpty
                                ? FileImage(File(item.img))
                                : const AssetImage('assets/images/person.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
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
                    ),
                  ],
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
                          'Ligar',
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
                        'Editar',
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
                        'Excluir',
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
