import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../widgets/contact_tile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Contact> _contacts = [
    Contact(name: 'John Appleseed', phoneNumber: '080-1111-1111'),
    Contact(name: 'Kate Bell', phoneNumber: '080-2222-2222'),
    Contact(name: 'Anna Haro', phoneNumber: '080-3333-3333'),
    Contact(name: 'Daniel Higgins Jr.', phoneNumber: '080-4444-4444'),
    Contact(name: 'David Taylor', phoneNumber: '080-5555-5555'),
    Contact(name: 'Hank M. Zakroff', phoneNumber: '080-6666-6666'),
  ];

  List<Map<String, String>> _places = [];
  bool _isLoading = false;
  String _searchKeyword = '';
  String? _errorMessage;

  // 連絡先をアルファベットごとにグループ化する関数
  Map<String, List<Contact>> _groupContacts(List<Contact> contacts) {
    final Map<String, List<Contact>> grouped = {};
    for (final contact in contacts) {
      String key = '';
      if (contact.name.isNotEmpty) {
        key = contact.name[0].toUpperCase();
        if (!RegExp(r'[A-Z]').hasMatch(key)) {
          key = '#';
        }
      } else {
        key = '#';
      }
      grouped.putIfAbsent(key, () => []).add(contact);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<String, List<Contact>> sortedGrouped = {
      for (var k in sortedKeys) k: grouped[k]!,
    };
    return sortedGrouped;
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts =
        _contacts
            .where(
              (c) =>
                  c.name.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
                  c.phoneNumber.contains(_searchKeyword),
            )
            .toList();
    final groupedContacts = _groupContacts(filteredContacts);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('連絡先'),
        previousPageTitle: 'リスト',
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: _requestPermissions,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: CupertinoSearchTextField(
                placeholder: '検索',
                onChanged: (value) {
                  setState(() {
                    _searchKeyword = value;
                  });
                  _searchNearbyPlaces(value);
                },
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      child: const Text('設定を開く'),
                      onPressed: openAppSettings,
                    ),
                  ],
                ),
              ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : ListView.builder(
                        itemCount: groupedContacts.length,
                        itemBuilder: (context, sectionIndex) {
                          final sectionKey = groupedContacts.keys.elementAt(
                            sectionIndex,
                          );
                          final sectionContacts = groupedContacts[sectionKey]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  sectionKey,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: CupertinoColors.systemGrey,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              ...sectionContacts.map(
                                (c) => ContactTile(contact: c),
                              ),
                            ],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchNearbyPlaces(String keyword) async {
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${position.latitude},${position.longitude}'
        '&radius=2000'
        '&keyword=$keyword'
        '&type=restaurant'
        '&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        final filtered =
            results
                .where((place) {
                  final rating = (place['rating'] ?? 0).toDouble();
                  return rating >= 4.0;
                })
                .map<Map<String, String>>((place) {
                  return {
                    'name': place['name'],
                    'rating': place['rating'].toString(),
                    'address': place['vicinity'] ?? '',
                  };
                })
                .toList();

        setState(() {
          _places = filtered;
        });
      } else {
        print("Failed to fetch places: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 連絡先と位置情報の権限を同時にリクエスト
      Map<Permission, PermissionStatus> statuses =
          await [Permission.contacts, Permission.location].request();

      // 権限の状態を確認
      bool contactsGranted = statuses[Permission.contacts]?.isGranted ?? false;
      bool locationGranted = statuses[Permission.location]?.isGranted ?? false;

      if (!contactsGranted || !locationGranted) {
        setState(() {
          _errorMessage = 'アプリの使用には連絡先と位置情報の権限が必要です。設定から許可してください。';
        });
        return;
      }

      // 権限が許可された場合、連絡先を取得
      await _fetchContacts();
    } catch (e) {
      setState(() {
        _errorMessage = '権限の確認中にエラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchContacts() async {
    try {
      // ここで端末の連絡先を取得する処理を実装
      // 例: contacts_serviceパッケージを使う場合
      // Iterable<device_contacts.Contact> contacts = await device_contacts.ContactsService.getContacts(withThumbnails: false);
      // setState(() { ... });
    } catch (e) {
      setState(() {
        _errorMessage = '連絡先の取得中にエラーが発生しました: $e';
      });
    }
  }
}
