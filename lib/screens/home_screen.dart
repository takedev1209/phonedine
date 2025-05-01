import 'package:flutter/cupertino.dart';
import '../models/contact.dart';
import '../widgets/contact_tile.dart';
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
    Contact(name: 'たけうち　しょうたろう', phoneNumber: '080-6666-6666'),
    Contact(name: 'さとう　たける', phoneNumber: '080-6666-6666'),
    Contact(name: 'よしおか　あきら', phoneNumber: '080-6666-6666'),
    Contact(name: 'ぱしおか　あきら', phoneNumber: '080-6666-6666'),
  ];

  bool _isLoading = false;
  String _searchKeyword = '';
  String? _errorMessage;

  // ひらがな・カタカナ・漢字の先頭文字を五十音の行頭に変換する関数
  String _getKanaGroup(String name) {
    if (name.isEmpty) return '#';
    final first = name[0];
    // ひらがな・カタカナをひらがなに正規化
    final hira = first.replaceAllMapped(
      RegExp(r'[ァ-ン]'),
      (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x60),
    );
    // 五十音の行頭リスト
    const List<String> gojuon = [
      'あ',
      'か',
      'さ',
      'た',
      'な',
      'は',
      'ま',
      'や',
      'ら',
      'わ',
    ];
    const List<List<String>> gojuonTable = [
      ['あ', 'い', 'う', 'え', 'お'],
      ['か', 'き', 'く', 'け', 'こ', 'が', 'ぎ', 'ぐ', 'げ', 'ご'],
      ['さ', 'し', 'す', 'せ', 'そ', 'ざ', 'じ', 'ず', 'ぜ', 'ぞ'],
      ['た', 'ち', 'つ', 'て', 'と', 'だ', 'ぢ', 'づ', 'で', 'ど'],
      ['な', 'に', 'ぬ', 'ね', 'の'],
      [
        'は',
        'ひ',
        'ふ',
        'へ',
        'ほ',
        'ば',
        'び',
        'ぶ',
        'べ',
        'ぼ',
        'ぱ',
        'ぴ',
        'ぷ',
        'ぺ',
        'ぽ',
      ],
      ['ま', 'み', 'む', 'め', 'も'],
      ['や', 'ゆ', 'よ'],
      ['ら', 'り', 'る', 'れ', 'ろ'],
      ['わ', 'を', 'ん'],
    ];
    for (int i = 0; i < gojuonTable.length; i++) {
      if (gojuonTable[i].contains(hira)) {
        return gojuon[i];
      }
    }
    // 英字の場合は大文字で返す
    if (RegExp(r'[A-Za-z]').hasMatch(first)) {
      return first.toUpperCase();
    }
    // それ以外は#
    return '#';
  }

  // 連絡先をアルファベット・五十音ごとにグループ化する関数
  Map<String, List<Contact>> _groupContacts(List<Contact> contacts) {
    final Map<String, List<Contact>> grouped = {};
    for (final contact in contacts) {
      String key = _getKanaGroup(contact.name);
      grouped.putIfAbsent(key, () => []).add(contact);
    }
    final sortedKeys =
        grouped.keys.toList()..sort((a, b) {
          // 五十音順＋アルファベット順＋#
          const gojuonOrder = [
            'あ',
            'か',
            'さ',
            'た',
            'な',
            'は',
            'ま',
            'や',
            'ら',
            'わ',
          ];
          if (gojuonOrder.contains(a) && gojuonOrder.contains(b)) {
            return gojuonOrder.indexOf(a).compareTo(gojuonOrder.indexOf(b));
          } else if (gojuonOrder.contains(a)) {
            return -1;
          } else if (gojuonOrder.contains(b)) {
            return 1;
          } else if (a == '#') {
            return 1;
          } else if (b == '#') {
            return -1;
          } else {
            return a.compareTo(b);
          }
        });
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
          onPressed: _requestPermissions,
          child: const Icon(CupertinoIcons.refresh),
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
                      onPressed: openAppSettings,
                      child: const Text('設定を開く'),
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
