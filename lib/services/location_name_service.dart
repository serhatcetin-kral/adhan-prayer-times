import 'package:geocoding/geocoding.dart';

class LocationNameService {
  static Future<String> getLocationName(
      double latitude,
      double longitude,
      ) async {
    try {
      final placemarks =
      await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return "Current location";
      }

      final p = placemarks.first;

      final city = p.locality;
      final district = p.subAdministrativeArea;
      final state = p.administrativeArea; // 🔥 added
      final country = p.country;

      if (city != null && city.isNotEmpty) {
        return district != null && district.isNotEmpty
            ? "$city, $district"
            : city;
      }

      if (district != null && district.isNotEmpty) {
        return district;
      }

      if (state != null && state.isNotEmpty) {
        return state;
      }

      if (country != null && country.isNotEmpty) {
        return country;
      }

      return "Current location";
    } catch (e) {
      return "Current location";
    }
  }
}