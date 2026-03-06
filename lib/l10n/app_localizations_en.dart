// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get contacts => 'Contacts';

  @override
  String get search => 'Search';

  @override
  String get noPhoneNumber => 'No Phone Number';

  @override
  String get noPhoneNumberMessage =>
      'Could not get the phone number for this place';

  @override
  String get error => 'Error';

  @override
  String get cannotOpenMap => 'Could not open map application';

  @override
  String get ok => 'OK';

  @override
  String get settings => 'Open Settings';

  @override
  String get permissionRequired =>
      'Contacts and location permissions are required. Please enable them in settings.';

  @override
  String permissionError(Object error) {
    return 'Error checking permissions: $error';
  }

  @override
  String contactsError(Object error) {
    return 'Error fetching contacts: $error';
  }

  @override
  String placesError(Object error) {
    return 'Error searching Google Places: $error';
  }
}
