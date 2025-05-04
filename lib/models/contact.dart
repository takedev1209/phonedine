class Contact {
  final String name;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? placeId;

  Contact({
    required this.name,
    required this.phoneNumber,
    this.latitude,
    this.longitude,
    this.placeId,
  });
}
