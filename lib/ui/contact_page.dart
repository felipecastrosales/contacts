import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'package:contacts/helpers/contact_helper.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

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
  String imagePicked = '';
  String initialCountry = 'NG';
  PhoneNumber number = PhoneNumber(isoCode: 'BR');

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      isEditMode = true;
      _editedContact = Contact.fromMap(contact!.toMap());
      imagePicked = _editedContact.img;
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
    imagePicked = '';
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
        ].any((c) => c.text.isNotEmpty) ||
        imagePicked.isNotEmpty;

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
                : 'New Contact',
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
              const SizedBox(height: 24),
              GestureDetector(
                child: SizedBox.square(
                  dimension: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: ColoredBox(
                      color: Colors.grey[300]!,
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
                ),
                onTap: () async {
                  try {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );

                    if (file == null) {
                      return;
                    }

                    setState(() {
                      imagePicked = file.path;
                      _editedContact = _editedContact.copyWith(img: file.path);
                    });
                  } catch (e) {
                    debugPrint('Error on pick image: $e');
                  }
                },
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                focusNode: _nameFocus,
                decoration: AppInputStyle.inputDecoration('Name', 'Name'),
                onChanged: (text) {
                  setState(() {
                    _editedContact = _editedContact.copyWith(name: text);
                    nameController.text = text;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: AppInputStyle.inputDecoration('Email', 'Email'),
                onChanged: (text) {
                  setState(() {
                    _editedContact = _editedContact.copyWith(email: text);
                    emailController.text = text;
                  });
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    _editedContact =
                        _editedContact.copyWith(phone: number.phoneNumber);
                  });
                },
                onSaved: (PhoneNumber number) {
                  setState(() {
                    _editedContact =
                        _editedContact.copyWith(phone: number.phoneNumber);
                  });
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  useBottomSheetSafeArea: true,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: const TextStyle(color: Colors.black),
                initialValue: number,
                textFieldController: phoneController,
                formatInput: true,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                inputBorder: const OutlineInputBorder(),
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
            title: const Text('Discard changes?'),
            content: const Text('If you leave, your changes will be lost.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Yes'),
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

class AppInputStyle {
  static inputDecoration(
    String labelText,
    String hintText,
  ) =>
      InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.blue),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.orange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: Colors.grey[300]!),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
            width: 1,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          borderSide: BorderSide(width: 1, color: Colors.black),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
            width: 1,
            color: Colors.yellowAccent,
          ),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Color(
            0xFFB3B1B1,
          ),
        ),
      );
}
