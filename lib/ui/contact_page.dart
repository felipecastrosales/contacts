import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:contacts/helpers/contact_helper.dart';

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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  late Contact _editedContact;

  Contact? get contact => widget.contact;

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      isEditMode = true;
      _editedContact = Contact.fromMap(contact!.toMap());
    } else {
      _editedContact = Contact.empty();
    }

    nameController.text = _editedContact.name;
    emailController.text = _editedContact.email;
    phoneController.text = _editedContact.phone;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    _nameFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasChangeOnControllers = [
      nameController,
      emailController,
      phoneController,
    ].any((c) => c.text.isNotEmpty);

    final isDifferentContact = _editedContact != contact;
    final hasEdit = isEditMode ? isDifferentContact : hasChangeOnControllers;

    return PopScope(
      onPopInvoked: (onPopInvoked) {
        if (onPopInvoked && !hasEdit) {
          _requestPop(hasEdit);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              _requestPop(hasEdit);
            },
          ),
          title: Text(
            _editedContact.name.isNotEmpty
                ? _editedContact.name
                : 'Adicionar Contato',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name.isNotEmpty) {
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
                child: SizedBox.square(
                  dimension: 120,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: _editedContact.img.isNotEmpty
                        ? Image.file(
                            File(_editedContact.img),
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.add_a_photo,
                            size: 60,
                            color: Colors.grey[700],
                          ),
                  ),
                ),
                onTap: () async {
                  final file = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );

                  if (file == null) {
                    return;
                  }

                  setState(() {
                    _editedContact = _editedContact.copyWith(img: file.path);
                  });
                },
              ),
              TextField(
                controller: nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (text) {
                  setState(() {
                    _editedContact = _editedContact.copyWith(name: text);
                    nameController.text = text;
                  });
                },
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (text) {
                  setState(() {
                    _editedContact = _editedContact.copyWith(email: text);
                    emailController.text = text;
                  });
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                onChanged: (text) {
                  setState(() {
                    _editedContact = _editedContact.copyWith(phone: text);
                    phoneController.text = text;
                  });
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestPop(bool hasEdit) {
    if (hasEdit) {
      showDialog(
        context: context,
        useRootNavigator: false,
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
      return;
    }

    Navigator.of(context).maybePop();
  }
}
