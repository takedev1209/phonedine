import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PlacesService {
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';

  Future<List<Map<String, dynamic>>> searchPlaces(
    String keyword,
    String location,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl?query=$keyword&type=restaurant&location=$location&radius=3000&language=${Localizations.localeOf(navigatorKey.currentContext!).languageCode}&opennow=true&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(data['results']);
      // 上位20件を対象に並列でPlace Details APIを呼び出し（多めに取得しておく）
      final topResults = results.take(20).toList();
      // ratingとuser_ratings_totalでソートし、上位10件のみ返す
      topResults.sort((a, b) {
        double ratingA = (a['rating'] ?? 0).toDouble();
        double ratingB = (b['rating'] ?? 0).toDouble();
        int reviewsA = (a['user_ratings_total'] ?? 0) as int;
        int reviewsB = (b['user_ratings_total'] ?? 0) as int;
        if (ratingA != ratingB) {
          return ratingB.compareTo(ratingA);
        } else {
          return reviewsB.compareTo(reviewsA);
        }
      });
      return topResults.take(10).toList();
    } else {
      throw Exception('Failed to load places');
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
