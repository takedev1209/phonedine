import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../widgets/contact_tile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('連絡先'),
        previousPageTitle: 'リスト',
        trailing: Icon(CupertinoIcons.add),
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
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : ListView(
                        children: [
                          if (filteredContacts.isNotEmpty)
                            ...filteredContacts.map(
                              (c) => ContactTile(contact: c),
                            ),
                          if (_places.isNotEmpty) const Divider(),
                          ..._places.map(
                            (place) => ListTile(
                              title: Text(place['name'] ?? ''),
                              subtitle: Text(
                                '${place['rating']} ⭐ - ${place['address']}',
                              ),
                            ),
                          ),
                        ],
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
                  return rating >= 4.0; // ★ここを設定変更可能に拡張可
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
}
