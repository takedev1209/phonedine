class Contact {
  final String name; // 名前
  final String phoneNumber; // 電話番号
  final double? latitude; // 緯度（オプション）
  final double? longitude; // 経度（オプション）
  final String? placeId; // Google Places APIの場所ID（オプション）

  Contact({
    required this.name, // 名前は必須
    required this.phoneNumber, // 電話番号は必須
    this.latitude, // 緯度は任意
    this.longitude, // 経度は任意
    this.placeId, // 場所IDは任意
  });
}
