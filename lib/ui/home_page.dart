import 'dart:io';

import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAZ, orderZA }


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper contactHelper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  void _getAllContacts(){
    contactHelper.getAllContacts().then((list){
      setState((){
        contacts = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de A-Z'),
                value: OrderOptions.orderAZ
              ),
              const PopupMenuItem<OrderOptions>(
                  child: Text('Ordenar de Z-A'),
                  value: OrderOptions.orderZA
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index){
          return _contactCard(context, contacts[index]);
        },
      )
    );
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderAZ:
        contacts.sort((a,b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderZA:
        contacts.sort((a,b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState((){});
  }

  void _showContactPage({Contact contact}) async{
    final contactSaved = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => ContactPage(contact: contact)
    ));

    if (contactSaved != null){
      if (contact != null){
        await contactHelper.updateContact(contactSaved);
      }
      else {
        await contactHelper.saveContact(contactSaved);
      }
      _getAllContacts();
    }
  }

  void _showOptions(BuildContext context, Contact contact){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){},
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text('Ligar',
                        style: TextStyle(color: Colors.red, fontSize: 20.0)),
                    onPressed: (){
                      launch('tel:${contact.phone}');
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text('Editar',
                        style: TextStyle(color: Colors.red, fontSize: 20.0)),
                    onPressed: (){
                      Navigator.pop(context);
                      _showContactPage(contact: contact);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text('Excluir',
                        style: TextStyle(color: Colors.red, fontSize: 20.0)),
                    onPressed: (){
                      contactHelper.deleteContact(contact.id);
                      Navigator.pop(context);
                      _getAllContacts();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _contactCard(BuildContext context, Contact contact){
    return GestureDetector(
      onTap: () => _showOptions(context, contact),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contact.img == null ?
                    AssetImage("images/person.png"):
                    FileImage(File(contact.img))
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.only(left:10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contact.name ?? "", style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(contact.email ?? "", style: TextStyle(fontSize: 16.0)),
                    Text(contact.phone ?? "", style: TextStyle(fontSize: 16.0))
                  ],
                )
              )
            ],
          )
        )
      ),
    );
  }
}
