import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  bool _isLoading = false;
  bool _hasMoreContacts = true;
  final _scrollController = ScrollController();
  final int _batchSize = 50; // Define batch size
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _requestPermissionAndLoadContacts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionAndLoadContacts() async {
    if (await Permission.contacts.request().isGranted) {
      _loadContacts();
    } else {
      print('Contact permission denied');
    }
  }

  Future<void> _loadContacts() async {
    if (_isLoading || !_hasMoreContacts) return;

    setState(() => _isLoading = true);

    try {
      final batchContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      setState(() {
        _contacts.addAll(batchContacts.sublist(
          _currentOffset,
          (_currentOffset + _batchSize > batchContacts.length)
              ? batchContacts.length
              : _currentOffset + _batchSize,
        ));
        _currentOffset += _batchSize;
        _hasMoreContacts = _currentOffset < batchContacts.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading contacts: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Contact')),
      body: _isLoading && _contacts.isEmpty
          ? Center(child: CircularProgressIndicator()) // Initial loading indicator
          : ListView.builder(
        itemCount: _contacts.length + (_hasMoreContacts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _contacts.length && _hasMoreContacts) {
            return Center(child: CircularProgressIndicator());
          }

          final contact = _contacts[index];
          return ListTile(
            title: Text(contact.displayName ?? 'No Name'),
            subtitle: Text(
              contact.phones.isNotEmpty ? contact.phones.first.number : 'No Phone',
            ),
            onTap: () {
              // Handle contact selection logic here
            },
          );
        },
        controller: _scrollController,
      ),
    );
  }
}
