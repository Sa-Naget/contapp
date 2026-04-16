// ignore_for_file: deprecated_member_use

import 'dart:io';

import '../models/contact.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context){
    final hasPhoto = contact.photoPath != null && contact.photoPath!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: Colors.pink.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade100.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18.0),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 38.0,
                    backgroundColor: Colors.pink.shade50,
                    backgroundImage: hasPhoto
                        ? FileImage(File(contact.photoPath!)) as ImageProvider
                        : null,
                    child: !hasPhoto
                        ? Text(
                            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 28.0,
                              color: Colors.pink.shade700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14.0),
                  Container(height: 76.0, width: 1.0, color: Colors.pink.shade100),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.pink.shade900,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          contact.phone,
                          style: TextStyle(fontSize: 16, color: Colors.pink.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}