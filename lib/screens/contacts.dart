import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../classes/app_contact.dart';
import '../classes/data_base.dart';
import 'add_contact.dart';
import 'edit_contact.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late Future<List<AppContact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _fetchContacts();
  }

  Future<List<AppContact>> _fetchContacts() async {
    try {
      Database database = await AppDataBase().database;
      final contacts = await AppContact.getAllContacts(database);
      print('Fetched contacts: ${contacts.length}');
      return contacts;
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  Future<void> _deleteContact(AppContact contact) async {
    try {
      if (contact.id != null) {
        Database database = await AppDataBase().database;
        await AppContact.deleteContact(contact.id!, database);

        setState(() {
          _contactsFuture = _fetchContacts();
        });
      } else {
        print('Contact ID is null. Cannot delete.');
      }
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  void _showDeleteConfirmationDialog(AppContact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Contact"),
          content: Text("Are you sure you want to delete this contact?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteContact(contact);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trusted Contacts'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<AppContact>>(
              future: _contactsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No contacts found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final contact = snapshot.data![index];
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(contact.name),
                        subtitle: Text('Phone: ${contact.number}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditContactScreen(contactId: contact.id!),
                                  ),
                                );

                                setState(() {
                                  _contactsFuture = _fetchContacts();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmationDialog(contact);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddContactScreen()),
                    );

                    setState(() {
                      _contactsFuture = _fetchContacts();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Add'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    addFromContacts(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Add from Contacts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void addFromContacts(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> phoneContacts = await FlutterContacts.getContacts(withProperties: true);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select a Contact'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: phoneContacts.length,
                  itemBuilder: (context, index) {
                    Contact contact = phoneContacts[index];

                    if (contact.phones.isNotEmpty) {
                      return ListTile(
                        title: Text(contact.displayName ?? 'No Name'),
                        subtitle: Text(contact.phones.first.number ?? 'No Number'),
                        onTap: () async {
                          await _insertSelectedContact(contact);

                          setState(() {
                            _contactsFuture = _fetchContacts();
                          });

                          Navigator.pop(context);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            );
          },
        );
      } else {
        print('Permission denied to access contacts.');
      }
    }
  }

  Future<void> _insertSelectedContact(Contact contact) async {
    Database database = await AppDataBase().database;

    String phoneNumber = contact.phones.first.number ?? '';

    AppContact newContact = AppContact(
      name: contact.displayName ?? 'No Name',
      appUserId: '',
      number: phoneNumber,
      publicKey: '',
      appId: '',
      userId: '',
    );

    try {
      await AppContact.insertAppContact(newContact, database);
      print('Contact from phone inserted successfully');
    } catch (e) {
      print('Error inserting contact from phone: $e');
    }
  }
}
