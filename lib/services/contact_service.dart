import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class ContactService {
  static Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<List<Contact>> getContacts() async {
    try {
      final contacts = await ContactsService.getContacts();
      return contacts.toList();
    } catch (e) {
      developer.log('連絡先の取得に失敗しました: $e');
      return [];
    }
  }

  static Future<bool> isFirstLaunch() async {
    // TODO: 初回起動かどうかを確認するロジックを実装
    return true;
  }
}
