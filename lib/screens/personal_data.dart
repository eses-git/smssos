import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../classes/app_user.dart';
import '../classes/data_base.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PersonalDataScreen extends StatefulWidget {
  @override
  _PersonalDataScreenState createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Initialize the database
 //   final appDatabase = AppDataBase();

   Database database = await AppDataBase().database;
    final secureStorage = FlutterSecureStorage();
    final userId = await secureStorage.read(key: 'userId');

    if (userId != null) {
      // Retrieve the user data
      AppUser? user = await AppUser.getAppUserById(userId, database);

      // If user data is not null, update the text controllers
      if (user != null) {
        setState(() {
          _nameController.text = user.name ?? '';  // If user.name is null, set it to an empty string
          _emailController.text = user.email ?? ''; // If user.email is null, set it to an empty string
          _phoneController.text = user.phone ?? ''; // If user.phone is null, set it to an empty string
        });
      }
    } else {
      // Handle the case where userId is null
      print("User ID is null");
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      // Access the already initialized database
      Database database = await AppDataBase().database;
      final secureStorage = FlutterSecureStorage();
      final userId = await secureStorage.read(key: 'userId');

      if (userId != null) {
        // Fetch the user by userId
        AppUser? user = await AppUser.getAppUserById(userId, database);

        if (user != null) {
          // Update the user object with new data
          user = AppUser(
            userId: user.userId,
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            dateCreation: user.dateCreation,  // Keep original creation date
            appAppId: user.appAppId,          // Keep original appAppId
            publicKey: user.publicKey,        // Keep original public key
          );

          await AppUser.updateAppUser(user, database);


          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data updated successfully')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Data'),
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
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Regular expression for email validation
                  String pattern = r'^[^@]+@[^@]+\.[^@]+';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Regular expression for phone number validation
                  String pattern = r'^\+?[0-9]{10,15}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}