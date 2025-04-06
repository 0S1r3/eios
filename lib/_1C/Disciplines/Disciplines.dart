class Disciplines {
  final String base;
  final String fastEducation;
  final List<String> teachers;
  final int id;
  final String planNumber;
  final String year;
  final String faculty;
  final String educationForm;
  final String educationLevel;
  final String specialty;
  final String specialtyCod;
  final String profile;
  final String periodString;
  final int periodInt;
  final String title;
  final String language;

  Disciplines({
    required this.base,
    required this.fastEducation,
    required this.teachers,
    required this.id,
    required this.planNumber,
    required this.year,
    required this.faculty,
    required this.educationForm,
    required this.educationLevel,
    required this.specialty,
    required this.specialtyCod,
    required this.profile,
    required this.periodString,
    required this.periodInt,
    required this.title,
    required this.language,

  });

  factory Disciplines.fromJson(Map<String, dynamic> json) {
    return Disciplines(
      base: json['Base'] as String? ?? '',
      fastEducation: json['FastEducation'] as String? ?? '',
      teachers: (json['Teachers'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      id: json['Id'] as int? ?? 0,
      planNumber: json['PlanNumber'] as String? ?? '',
      year: json['Year'] as String? ?? '',
      faculty: json['Faculty'] as String? ?? '',
      educationForm: json['EducationForm'] as String? ?? '',
      educationLevel: json['EducationLevel'] as String? ?? '',
      specialty: json['Specialty'] as String? ?? '',
      specialtyCod: json['SpecialtyCod'] as String? ?? '',
      profile: json['Profile'] as String? ?? '',
      periodString: json['PeriodString'] as String? ?? '',
      periodInt: json['PeriodInt'] as int? ?? 0,
      title: json['Title'] as String? ?? '',
      language: json['Language'] as String? ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'Base': base,
      'FastEducation': fastEducation,
      'Teachers': teachers,
      'Id': id,
      'PlanNumber': planNumber,
      'Year': year,
      'Faculty': faculty,
      'EducationForm': educationForm,
      'EducationLevel': educationLevel,
      'Specialty': specialty,
      'SpecialtyCod': specialtyCod,
      'Profile': profile,
      'PeriodString': periodString,
      'PeriodInt': periodInt,
      'Title': title,
      'Language': language,
    };
  }
}
