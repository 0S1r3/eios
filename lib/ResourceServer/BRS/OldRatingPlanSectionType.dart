enum OldRatingPlanSectionType {
  exam,
  current,
  project,
}

extension OldRatingPlanSectionTypeExtension on OldRatingPlanSectionType {
  int? toJson() {
    switch (this) {
      case OldRatingPlanSectionType.exam:
        return 0;
      case OldRatingPlanSectionType.current:
        return 1;
      case OldRatingPlanSectionType.project:
        return 2;
    }
  }

  static OldRatingPlanSectionType fromJson(int? value) {
    switch (value) {
      case 0:
        return OldRatingPlanSectionType.exam;
      case 1:
        return OldRatingPlanSectionType.current;
      case 2:
        return OldRatingPlanSectionType.project;
      default:
        throw Exception("Неизвестное значение для OldRatingPlanSectionType: $value");
    }
  }
}
