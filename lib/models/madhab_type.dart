enum MadhabType {
  standard,
  hanafi,
}

extension MadhabTypeExtension on MadhabType {
  String get displayName {
    switch (this) {
      case MadhabType.standard:
        return "Shafi / Maliki / Hanbali";
      case MadhabType.hanafi:
        return "Hanafi";
    }
  }

  // ✅ IMPORTANT
  int get schoolId {
    switch (this) {
      case MadhabType.standard:
        return 0;
      case MadhabType.hanafi:
        return 1;
    }
  }
}