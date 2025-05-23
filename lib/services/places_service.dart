import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PlacesService {
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';

  Future<List<Map<String, dynamic>>> searchPlaces(
    String query,
    String location,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$location&radius=5000&language=${Localizations.localeOf(navigatorKey.currentContext!).languageCode}&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      return [];
    }
  }

  Future<String?> getPhoneNumber(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number&language=${Localizations.localeOf(navigatorKey.currentContext!).languageCode}&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result']?['formatted_phone_number'];
    } else {
      return null;
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
