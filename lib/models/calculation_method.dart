enum CalculationMethod {
  karachi,
  isna,
  mwl,
  makkah,
  egypt,
  turkey,
}

extension CalculationMethodExtension on CalculationMethod {
  String get displayName {
    switch (this) {
      case CalculationMethod.karachi:
        return "Karachi";
      case CalculationMethod.isna:
        return "ISNA (Islamic Society of North America)";
      case CalculationMethod.mwl:
        return "Muslim World League";
      case CalculationMethod.makkah:
        return "Umm al-Qura (Makkah)";
      case CalculationMethod.egypt:
        return "Egyptian";
      case CalculationMethod.turkey:
        return "Diyanet (Turkey)";
    }
  }

  // ✅ THIS IS THE IMPORTANT PART
  int get methodId {
    switch (this) {
      case CalculationMethod.karachi:
        return 1;
      case CalculationMethod.isna:
        return 2;
      case CalculationMethod.mwl:
        return 3;
      case CalculationMethod.makkah:
        return 4;
      case CalculationMethod.egypt:
        return 5;
      case CalculationMethod.turkey:
        return 13;
    }
  }
}