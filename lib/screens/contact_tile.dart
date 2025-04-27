import 'package:flutter/cupertino.dart';
import '../models/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;

  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(contact.name),
      subtitle: Text(contact.phoneNumber),
      onTap: () {
        // 電話発信などの処理をここに
      },
    );
  }
}
