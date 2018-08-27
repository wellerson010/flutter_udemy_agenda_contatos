import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';

import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameFocus = FocusNode();

  Contact _editedContact;
  bool _userEdited = false;

  Future<bool> _requestPopup() async {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Descartar alterações?'),
              content: Text('Se sair, as alterações serão perdidas.'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Sim'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPopup,
        child: Scaffold(
            appBar: AppBar(
                title: Text(_editedContact.name ?? 'Novo contato'),
                backgroundColor: Colors.red,
                centerTitle: true),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (_editedContact.name != null &&
                      _editedContact.name.isNotEmpty) {
                    Navigator.pop(context, _editedContact);
                  } else {
                    FocusScope.of(context).requestFocus(_nameFocus);
                  }
                },
                child: Icon(Icons.save),
                backgroundColor: Colors.red),
            body: SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(children: [
                  GestureDetector(
                      child: Container(
                          width: 140.0,
                          height: 140.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: _editedContact.img != null
                                      ? FileImage(File(_editedContact.img))
                                      : AssetImage('images/person.png')))),
                    onTap: (){
                        ImagePicker.pickImage(source: ImageSource.camera).then((file){
                          if (file == null) return;
                          setState((){
                            _editedContact.img = file.path;
                          });
                        });
                    }
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Nome"),
                    onChanged: (text) {
                      _userEdited = true;
                      setState(() {
                        _editedContact.name = text;
                      });
                    },
                    controller: _nameController,
                    focusNode: _nameFocus,
                  ),
                  TextField(
                      decoration: InputDecoration(labelText: "Email"),
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.email = text;
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController),
                  TextField(
                    decoration: InputDecoration(labelText: "Phone"),
                    onChanged: (text) {
                      _userEdited = true;
                      _editedContact.phone = text;
                    },
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                  )
                ]))));
  }

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }
}
