import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import 'dart:developer' as developer;

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  void _call(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      // ignore: avoid_print
      print('電話をかけられません');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(contact.name)),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(
              CupertinoIcons.person_crop_circle_fill,
              size: 100,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 24),
            Text(
              contact.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              contact.phoneNumber,
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 40),
            CupertinoButton.filled(
              child: const Text('電話をかける'),
              // onPressed: () => _call(contact.phoneNumber),
              onPressed: () {
                // debugPrint('📞 発信先: ${contact.phoneNumber}');
                developer.log('📞 発信先: ${contact.phoneNumber}');

                _call(contact.phoneNumber);
              },
            ),
          ],
        ),
      ),
    );
  }
}
