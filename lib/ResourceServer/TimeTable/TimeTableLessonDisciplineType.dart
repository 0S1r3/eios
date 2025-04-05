enum TimeTableLessonDisciplineType {
  defaultType,
  consultation,
  offset,
  exam,
  course,
}

extension TimeTableLessonDisciplineTypeExtension on TimeTableLessonDisciplineType {
  int toJson() {
    switch (this) {
      case TimeTableLessonDisciplineType.defaultType:
        return 0;
      case TimeTableLessonDisciplineType.consultation:
        return 1;
      case TimeTableLessonDisciplineType.offset:
        return 2;
      case TimeTableLessonDisciplineType.exam:
        return 3;
      case TimeTableLessonDisciplineType.course:
        return 4;
    }
  }

  static TimeTableLessonDisciplineType fromJson(int value) {
    switch (value) {
      case 0:
        return TimeTableLessonDisciplineType.defaultType;
      case 1:
        return TimeTableLessonDisciplineType.consultation;
      case 2:
        return TimeTableLessonDisciplineType.offset;
      case 3:
        return TimeTableLessonDisciplineType.exam;
      case 4:
        return TimeTableLessonDisciplineType.course;
      default:
        throw Exception("Unknown TimeTableLessonDisciplineType: $value");
    }
  }
}
