// class ZikrModel {
//   final String id;
//   final String arabic;
//   final String english;
//
//   ZikrModel({
//     required this.id,
//     required this.arabic,
//     required this.english,
//   });
// }

class ZikrModel {
  final String id;
  final String arabic;
  final String english;

  const ZikrModel({
    required this.id,
    required this.arabic,
    required this.english,
  });
  bool get isCustom => id.startsWith('custom_');

}
