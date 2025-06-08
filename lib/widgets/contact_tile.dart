import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/places_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      if (!context.mounted) return;
      if (phone != null && phone.isNotEmpty) {
        _call(phone);
      } else {
        final l10n = AppLocalizations.of(context)!;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(l10n.noPhoneNumber),
            content: Text(l10n.noPhoneNumberMessage),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.ok),
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
      Uri url;
      if (contact.placeId != null && contact.placeId!.isNotEmpty) {
        // Place IDがある場合はGoogleマップの店舗詳細画面を開く
        final encodedName = Uri.encodeComponent(contact.name);
        url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedName&query_place_id=${contact.placeId}',
        );
      } else {
        // Place IDがなければ従来通り経路案内
        final encodedName = Uri.encodeComponent(contact.name);
        url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$encodedName@${contact.latitude},${contact.longitude}&travelmode=walking',
        );
      }
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        final l10n = AppLocalizations.of(context)!;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(l10n.error),
            content: Text(l10n.cannotOpenMap),
            actions: [
              CupertinoDialogAction(
                child: Text(l10n.ok),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } else {
      _callOrFetchAndCall(context);
    }
  }

  Widget _buildSeparator(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Container(
      height: 0.5,
      color: isDarkMode
          ? CupertinoColors.systemGrey.withOpacity(0.6)
          : CupertinoColors.separator,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Column(
      children: [
        _buildSeparator(context),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  contact.name,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.label,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                    fontFamily: 'Roboto',
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
