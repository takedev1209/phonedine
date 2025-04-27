import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../screens/contact_detail_screen.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({super.key, required this.contact});

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => ContactDetailScreen(contact: contact)),
    );
  }

  void _call(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      print('電話をかけられません');
    }
  }

  Widget _buildSeparator() {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator,
      margin: const EdgeInsets.only(left: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSeparator(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _navigateToDetail(context),
                  child: Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 17,
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 30,
                onPressed: () => _call(contact.phoneNumber),
                child: const Icon(
                  CupertinoIcons.phone,
                  size: 24,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
