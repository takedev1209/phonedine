import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/places_service.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final PlacesService _placesService = PlacesService();

  ContactTile({super.key, required this.contact});

  void _call(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      developer.log('電話をかけられません');
    }
  }

  void _callOrFetchAndCall(BuildContext context) async {
    if (contact.phoneNumber.isNotEmpty) {
      _call(contact.phoneNumber);
    } else if (contact.placeId != null) {
      // Place Details APIで電話番号取得
      final phone = await _placesService.getPhoneNumber(contact.placeId!);
      if (phone != null && phone.isNotEmpty) {
        _call(phone);
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('電話番号なし'),
            content: const Text('この店舗の電話番号は取得できませんでした'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openMapOrCall(BuildContext context) async {
    if (contact.latitude != null && contact.longitude != null) {
      // Google Mapsの経路案内URL
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${contact.latitude},${contact.longitude}&travelmode=walking',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('地図アプリを開けませんでした')),
        );
      }
    } else {
      _callOrFetchAndCall(context);
    }
  }

  Widget _buildSeparator() {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSeparator(),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.label,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (contact.latitude != null && contact.longitude != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 30,
                  onPressed: () => _openMapOrCall(context),
                  child: const Icon(
                    Icons.circle,
                    size: 11,
                    color: CupertinoColors.activeGreen,
                  ),
                ),
              const SizedBox(width: 5.0),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 30,
                onPressed: () => _callOrFetchAndCall(context),
                child: const Icon(
                  Icons.circle,
                  size: 11,
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
