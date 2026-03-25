import 'dart:math';

class QiblaService {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// Bearing from true north (0-360 degrees)
  static double bearingToKaaba({
    required double userLat,
    required double userLng,
  }) {
    final userLatRad = _degToRad(userLat);
    final userLngRad = _degToRad(userLng);
    final kaabaLatRad = _degToRad(kaabaLat);
    final kaabaLngRad = _degToRad(kaabaLng);

    final dLng = kaabaLngRad - userLngRad;

    final y = sin(dLng);
    final x = cos(userLatRad) * tan(kaabaLatRad) - sin(userLatRad) * cos(dLng);

    final bearingRad = atan2(y, x);
    return (_radToDeg(bearingRad) + 360) % 360;
  }

  static double normalizeAngle(double angle) {
    return ((angle % 360) + 360) % 360;
  }

  static double shortestAngleDifference(double target, double current) {
    double diff = normalizeAngle(target - current);
    if (diff > 180) diff -= 360;
    return diff;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / pi;
}