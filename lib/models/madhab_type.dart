enum MadhabType {
  shafi,
  hanafi,
  maliki,
  hanbali,
}

extension MadhabExtension on MadhabType {
  String get displayName {
    switch (this) {
      case MadhabType.shafi:
        return "Shafi";
      case MadhabType.hanafi:
        return "Hanafi";
      case MadhabType.maliki:
        return "Maliki";
      case MadhabType.hanbali:
        return "Hanbali";
    }
  }

  int get schoolId {
    switch (this) {
      case MadhabType.hanafi:
        return 1;
      default:
        return 0;
    }
  }
}