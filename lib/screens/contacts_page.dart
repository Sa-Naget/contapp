// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import '../db/db_helper.dart';
import '../models/contact.dart';
import '../widgets/contact_tile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

enum OrderOptions {
  aToZ,
  zToA,
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  bool _loading = true;
  OrderOptions _orderOptions = OrderOptions.aToZ;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await DBHelper.getContacts();
    setState(() {
      _contacts = _sortedContacts(contacts);
      _loading = false;
    });
  }

  List<Contact> _sortedContacts(List<Contact> contacts) {
    final sorted = List<Contact>.from(contacts);
    sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (_orderOptions == OrderOptions.zToA) {
      return sorted.reversed.toList();
    }
    return sorted;
  }

  Future<void> _addContact(String name, String phone, {String? photoPath}) async {
    if (name.trim().isEmpty || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hey, you miss a field there...')),
      );
      return;
    }

    try {
      await DBHelper.insertContact(Contact(name: name, phone: phone, photoPath: photoPath));
      await _loadContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hoorray! Say hi to $name!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oh no, $e')),
      );
    }
  }

  Future<void> _updateContact(Contact contact, String name, String phone, String? photoPath) async {
    if (name.trim().isEmpty || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hmm, nothing seems to be changed')),
      );
      return;
    }

    if (contact.id == null) return;

    try {
      await DBHelper.updateContact(Contact(
        id: contact.id,
        name: name,
        phone: phone,
        photoPath: photoPath,
      ));
      await _loadContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yey! Your contact have been updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uh oh, $e')),
      );
    }
  }

  void _showForm({Contact? contact}) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    String phoneNumber = contact?.phone ?? '';
    String? photoPath = contact?.photoPath;
    final initialPhone = PhoneNumber(
      isoCode: 'ID',
      phoneNumber: contact?.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(contact == null ? 'Add new contact?' : 'Edit contact?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.pink.shade100,
                    backgroundImage: photoPath != null && photoPath!.isNotEmpty
                        ? FileImage(File(photoPath!)) as ImageProvider<Object>
                        : null,
                    child: photoPath == null || photoPath!.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 44,
                            color: Colors.pink.shade700,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.pink.shade700,
                  ),
                  icon: const Icon(Icons.photo_camera_back_rounded),
                  label: Text(contact == null ? 'Add profile photo' : 'Change profile photo?'),
                  onPressed: () async {
                    final pickedImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 600,
                      imageQuality: 80,
                    );
                    if (pickedImage != null) {
                      setState(() => photoPath = pickedImage.path);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    phoneNumber = number.phoneNumber ?? '';
                  },
                  initialValue: initialPhone,
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DROPDOWN,
                    showFlags: true,
                    setSelectorButtonAsPrefixIcon: false,
                  ),
                  inputDecoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: Colors.pink.shade50,
                  ),
                  textStyle: TextStyle(color: Colors.pink.shade900),
                  formatInput: true,
                  keyboardType: TextInputType.phone,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.pink.shade900),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nevermind'),
            ),
            TextButton(
              onPressed: () async {
                if (contact == null) {
                  await _addContact(nameController.text, phoneNumber, photoPath: photoPath);
                } else {
                  await _updateContact(contact, nameController.text, phoneNumber, photoPath);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(contact == null ? 'Yeah' : 'Yes please'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Contact contact) async {
    if (contact.id == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nevermind'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteContact(contact);
            },
            child: const Text("I'm sure", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContact(Contact contact) async {
    if (contact.id == null) return;

    try {
      await DBHelper.deleteContact(contact.id!);
      await _loadContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted! Bye bye ${contact.name} :()')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uh oh. $e')),
      );
    }
  }

  Future<void> _callContact(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showUnableToLaunchMessage();
      }
    } catch (_) {
      _showUnableToLaunchMessage();
    }
  }

  void _showUnableToLaunchMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("I don't think you can launch the call app")),
    );
  }

  void _showOptions(BuildContext context, int index) {
    final contact = _contacts[index];
    final phone = contact.phone;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (phone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextButton(
                        child: const Text(
                          'Call them?',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _callContact(phone);
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextButton(
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showForm(contact: contact);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(contact);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _setOrder(OrderOptions order) {
    setState(() {
      _orderOptions = order;
      _contacts = _sortedContacts(_contacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruhesa's Contacts"),
        actions: [
          PopupMenuButton<OrderOptions>(
            iconColor: Colors.white,
            onSelected: _setOrder,
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.aToZ,
                child: Text('Sort from A-Z'),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.zToA,
                child: Text('Sort from Z-A'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1F6), Color(0xFFFFE3EA)],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _contacts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        "Doesn't seem like you know anyone yet...\nWhy don't you add some contacts?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.pink.shade700,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ContactTile(
                        contact: contact,
                        onTap: () => _showOptions(context, index),
                      );
                    },
                  ),
      ),
    );
  }
}
