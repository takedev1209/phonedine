import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({super.key, required this.contact});

  void _call(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      developer.log('電話をかけられません');
    }
  }

  Widget _buildSeparator() {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSeparator(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.label,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 30,
                onPressed: () => _call(contact.phoneNumber),
                child: const Icon(
                  Icons.circle,
                  size: 11,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(width: 5.0),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 30,
                onPressed: () => _call(contact.phoneNumber),
                child: const Icon(
                  Icons.circle,
                  size: 11,
                  color: CupertinoColors.activeGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
