enum MadhabType {
  hanafi,
  standard, // 👈 all others
}

extension MadhabExtension on MadhabType {
  String get displayName {
    switch (this) {
      case MadhabType.hanafi:
        return "Hanafi";
      case MadhabType.standard:
        return "Shafi / Maliki / Hanbali";
    }
  }

  int get schoolId {
    switch (this) {
      case MadhabType.hanafi:
        return 1;
      case MadhabType.standard:
        return 0;
    }
  }
}