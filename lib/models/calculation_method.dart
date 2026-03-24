enum CalculationMethod {
  isna,
  mwl,
  egypt,
  makkah,
  turkish,
  karachi,
}

extension CalculationMethodExtension on CalculationMethod {
  String get displayName {
    switch (this) {
      case CalculationMethod.isna:
        return "ISNA";
      case CalculationMethod.mwl:
        return "MWL";
      case CalculationMethod.egypt:
        return "Egypt";
      case CalculationMethod.makkah:
        return "Makkah";
      case CalculationMethod.turkish:
        return "Turkish";
      case CalculationMethod.karachi:
        return "Karachi";

    }
  }

  int get methodId {
    switch (this) {
      case CalculationMethod.isna:
        return 2;
      case CalculationMethod.mwl:
        return 3;
      case CalculationMethod.egypt:
        return 5;
      case CalculationMethod.makkah:
        return 4;
      case CalculationMethod.turkish:
        return 13;
      case CalculationMethod.karachi:
        return 1;
    }
  }
}