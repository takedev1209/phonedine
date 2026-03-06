// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get contacts => '連絡先';

  @override
  String get search => '検索';

  @override
  String get noPhoneNumber => '電話番号なし';

  @override
  String get noPhoneNumberMessage => 'この店舗の電話番号は取得できませんでした';

  @override
  String get error => 'エラー';

  @override
  String get cannotOpenMap => '地図アプリを開けませんでした';

  @override
  String get ok => 'OK';

  @override
  String get settings => '設定を開く';

  @override
  String get permissionRequired => '連絡先と位置情報の権限が必要です。設定から許可してください。';

  @override
  String permissionError(Object error) {
    return '権限の確認中にエラーが発生しました: $error';
  }

  @override
  String contactsError(Object error) {
    return '連絡先の取得中にエラーが発生しました: $error';
  }

  @override
  String placesError(Object error) {
    return 'Googleスポット検索中にエラーが発生しました: $error';
  }
}
