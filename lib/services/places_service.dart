import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PlacesService {
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/textsearch/json';

  // 2点間の距離を計算する関数（Haversine formula）
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 地球の半径（km）
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<List<Map<String, dynamic>>> searchPlaces(
    String keyword,
    String location,
  ) async {
    // 現在地の緯度・経度を取得
    final List<String> locationParts = location.split(',');
    final double currentLat = double.parse(locationParts[0]);
    final double currentLon = double.parse(locationParts[1]);

    final response = await http.get(
      Uri.parse(
        '$_baseUrl?query=$keyword&type=restaurant&location=$location&radius=3000&language=${Localizations.localeOf(navigatorKey.currentContext!).languageCode}&opennow=true&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(data['results']);

      // 各店舗に距離情報を追加
      for (var result in results) {
        final geometry = result['geometry'] as Map<String, dynamic>;
        final location = geometry['location'] as Map<String, dynamic>;
        final double lat = location['lat'].toDouble();
        final double lng = location['lng'].toDouble();

        // 距離を計算して追加
        result['distance'] =
            _calculateDistance(currentLat, currentLon, lat, lng);
      }

      // 上位20件を対象に並列でPlace Details APIを呼び出し（多めに取得しておく）
      final topResults = results.take(20).toList();

      // 評価とレビュー数でソート
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

      // 上位10件を取得
      final top10Results = topResults.take(10).toList();

      // 距離でソート
      top10Results.sort((a, b) {
        double distanceA = a['distance'] as double;
        double distanceB = b['distance'] as double;
        return distanceA.compareTo(distanceB);
      });

      return top10Results;
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
