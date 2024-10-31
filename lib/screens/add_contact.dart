import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../classes/app_contact.dart';
import '../classes/data_base.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void saveContact() {
    if (_formKey.currentState!.validate()) {
      // Save contact logic here
      Future<void> _saveContact() async {
        if (_formKey.currentState!.validate()) {
          // Access the already initialized database
          Database database = await AppDataBase().database;
          final secureStorage = FlutterSecureStorage();
          final userId = await secureStorage.read(key: 'userId');
          final appId = await secureStorage.read(key: 'appId');

          // Create a new contact object
          AppContact newContact = AppContact(
            name: _nameController.text,
            appUserId: '', // Replace with actual appUserId
            number: _phoneController.text,
            publicKey: '', // Replace with actual publicKey
            appId: appId, // Replace with actual appAppId
            userId: userId
          );

          try {
            print("Before inserting contact");
            await AppContact.insertAppContact(newContact, database);
            print("After inserting contact");
          } catch (e) {
            print("Error inserting contact: $e");
          }
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contact added successfully')),
          );

          Navigator.pop(context);
        }
      }

      _saveContact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
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
                    onPressed: saveContact,
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