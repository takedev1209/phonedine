// home_screen.dart
import 'package:flutter/cupertino.dart';
import '../models/contact.dart' as app_contact;
import '../widgets/contact_tile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<app_contact.Contact> _contacts = [];
  bool _isLoading = false;
  String _searchKeyword = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // まず現在の権限状態を確認
      bool hasPermission = await FlutterContacts.requestPermission();

      if (hasPermission) {
        await _fetchContacts();
      } else {
        setState(() {
          _errorMessage = '連絡先へのアクセス権限が必要です。設定から許可してください。';
        });
      }
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
      // デバイスの連絡先を取得（電話番号も含めて取得）
      final contacts =
          await FlutterContacts.getContacts(withProperties: true, sorted: true);

      setState(() {
        _contacts = contacts
            .map((contact) {
              // 電話番号がある連絡先のみを取得
              final phoneNumber = contact.phones.isNotEmpty
                  ? contact.phones.first.number
                      .replaceAll(RegExp(r'[^\d+]'), '')
                  : '';

              return app_contact.Contact(
                name: contact.displayName,
                phoneNumber: phoneNumber,
              );
            })
            // 電話番号がある連絡先のみをフィルタリング
            .where((contact) => contact.phoneNumber.isNotEmpty)
            .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = '連絡先の取得中にエラーが発生しました: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _contacts
        .where((c) =>
            c.name.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
            c.phoneNumber.contains(_searchKeyword))
        .toList();

    // 連絡先をグループ化
    final groupedContacts = _groupContacts(filteredContacts);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('連絡先'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _checkPermissions,
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
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                      itemCount: groupedContacts.length,
                      itemBuilder: (context, sectionIndex) {
                        final sectionKey =
                            groupedContacts.keys.elementAt(sectionIndex);
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
                                  fontFamily: '.SF Pro Text',
                                ),
                              ),
                            ),
                            ...sectionContacts
                                .map((c) => ContactTile(contact: c)),
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

  // ひらがな・カタカナ・漢字の先頭文字を五十音の行頭に変換する関数
  String _getKanaGroup(String name) {
    if (name.isEmpty) return '#';

    // デバッグ用にnameの内容を確認
    debugPrint('処理する名前: $name');

    final first = name[0];
    debugPrint('最初の文字: $first');

    // 英字の場合の処理を最初に行う
    if (RegExp(r'[A-Za-z]').hasMatch(first)) {
      final upperFirst = first.toUpperCase();
      debugPrint('英字を検出: $upperFirst');
      return upperFirst;
    }

    // ひらがな・カタカナをひらがなに正規化
    final hira = first.replaceAllMapped(
      RegExp(r'[ァ-ン]'),
      (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x60),
    );
    debugPrint('正規化後: $hira');

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
        'ぽ'
      ],
      ['ま', 'み', 'む', 'め', 'も'],
      ['や', 'ゆ', 'よ'],
      ['ら', 'り', 'る', 'れ', 'ろ'],
      ['わ', 'を', 'ん'],
    ];

    // 五十音のグループを探す
    for (int i = 0; i < gojuonTable.length; i++) {
      if (gojuonTable[i].contains(hira)) {
        debugPrint('五十音グループ検出: ${gojuon[i]}');
        return gojuon[i];
      }
    }

    // それ以外は#
    debugPrint('その他の文字として#を返す');
    return '#';
  }

  // 連絡先をアルファベット・五十音ごとにグループ化する関数
  Map<String, List<app_contact.Contact>> _groupContacts(
      List<app_contact.Contact> contacts) {
    final Map<String, List<app_contact.Contact>> grouped = {};

    // グループ化
    for (final contact in contacts) {
      String key = _getKanaGroup(contact.name);
      grouped.putIfAbsent(key, () => []).add(contact);
    }

    // キーのソート
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
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

        // aとbが両方とも五十音の場合
        if (gojuonOrder.contains(a) && gojuonOrder.contains(b)) {
          return gojuonOrder.indexOf(a).compareTo(gojuonOrder.indexOf(b));
        }
        // aが五十音の場合
        else if (gojuonOrder.contains(a)) {
          return -1;
        }
        // bが五十音の場合
        else if (gojuonOrder.contains(b)) {
          return 1;
        }
        // #の場合は最後に
        else if (a == '#') {
          return 1;
        } else if (b == '#') {
          return -1;
        }
        // それ以外（アルファベット）は通常のソート
        else {
          return a.compareTo(b);
        }
      });

    // ソートされたマップを作成（各グループ内も名前でソート）
    final sortedGrouped = {
      for (var k in sortedKeys)
        k: grouped[k]!..sort((a, b) => a.name.compareTo(b.name))
    };

    // デバッグ用に結果を出力
    debugPrint('グループ化結果:');
    sortedGrouped.forEach((key, value) {
      debugPrint('グループ $key: ${value.length}件');
    });

    return sortedGrouped;
  }
}
