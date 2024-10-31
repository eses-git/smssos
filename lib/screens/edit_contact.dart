import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../classes/app_contact.dart';
import '../classes/data_base.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditContactScreen extends StatefulWidget {
  final int contactId;

  EditContactScreen({required this.contactId});

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContactData();
  }

  Future<void> _loadContactData() async {
    try {
      Database database = await AppDataBase().database;
      AppContact? contact = await AppContact.getAppContactById(widget.contactId, database);

      if (contact != null) {
        setState(() {
          _nameController.text = contact.name;
          _phoneController.text = contact.number;
        });
      }
    } catch (e) {
      print('Error loading contact: $e');
    }
  }

  void _updateContact() async {
    if (_formKey.currentState!.validate()) {
      Database database = await AppDataBase().database;
      final secureStorage = FlutterSecureStorage();
      final userId = await secureStorage.read(key: 'userId');
      final appId = await secureStorage.read(key: 'appId');

      // Create an updated contact object
      AppContact updatedContact = AppContact(
        id: widget.contactId,
        name: _nameController.text,
        appUserId: '', // Replace with actual appUserId
        number: _phoneController.text,
        publicKey: '', // Replace with actual publicKey
        appId: appId, // Replace with actual appId
        userId: userId, // Replace with actual userId
      );

      try {
        await AppContact.updateAppContact(updatedContact, database);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact updated successfully')),
        );
        Navigator.pop(context); // Go back to the contact list
      } catch (e) {
        print('Error updating contact: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  String pattern = r'^\+?[0-9]{10,15}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _updateContact,
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
