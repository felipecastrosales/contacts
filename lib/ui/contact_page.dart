import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({
    super.key,
    this.contact,
  });

  final Contact? contact;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _userEdited = false;
  Contact? _editedContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _editedContact = Contact.fromMap(widget.contact!.toMap());
    }

    _nameController.text = _editedContact?.name ?? '';
    _emailController.text = _editedContact?.email ?? '';
    _phoneController.text = _editedContact?.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (onPopInvoked) {
        if (onPopInvoked) {
          _requestPop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _requestPop();
            },
          ),
          title: Text(
            _editedContact?.name ?? 'Adicionar Contato',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact?.name.isNotEmpty ?? false) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact?.img != null
                          ? FileImage(File(_editedContact!.img))
                          : const AssetImage('assets/images/person.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () async {
                  await ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((file) {
                    if (file == null) return;
                    setState(() {
                      _editedContact?.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact?.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact?.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Descartar alterações?'),
            content: const Text('Se você sair, as alterações serão perdidas.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Sim'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
