import 'package:flutter/material.dart';
import '../BRS/StudentSemester/StudentSemester.dart';
import '../ResourceServer/BRS/RecordBook.dart';
import '../Token/MRSUAPI.dart';
import '../Token/SharedPrefManager.dart';
import 'Screens/DisciplineScreen.dart';
import '../ResourceServer/BRS/Semester.dart';
import 'Screens/MessagesDisciplineScreen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final SharedPrefManager _manager = SharedPrefManager();
  Future<StudentSemester>? _futureSemester;
  List<Semester>? _semesters;
  Semester? _selectedSemester;
  late MrsuApi dataApi;
  late String _authHeader;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // Инициализируем данные: получаем список семестров и данные по выбранному семестру
  void _initData() async {
    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/');
    final accessToken = _manager.getAccessToken() ?? '';
    _authHeader = 'Bearer $accessToken';

    // Получаем список всех семестров
    _semesters = await dataApi.getSemester(_authHeader);

    if (_semesters == null || _semesters!.isEmpty) return;

    // Если в SharedPrefManager уже сохранён текущий семестр, используем его
    final currentSemesterData = _manager.getStudentSemester();
    if (currentSemesterData != null) {
      _selectedSemester = _semesters!.firstWhere(
            (s) =>
        s.year == currentSemesterData.year &&
            s.period == currentSemesterData.period,
        orElse: () => _semesters!.first,
      );
      setState(() {
        _futureSemester = Future.value(currentSemesterData);
      });
    } else {
      // Если данных нет, выбираем первый семестр из списка
      _selectedSemester = _semesters!.first;
      _futureSemester = dataApi.getStudentSemesterYearPeriod(
        _authHeader,
        _selectedSemester!.year,
        _selectedSemester!.period,
      );
      final semesterData = await _futureSemester;
      await _manager.saveStudentSemester(semesterData!);
      setState(() {});
    }
  }

  // Обработчик выбора нового семестра через диалог
  void _showSemesterDialog() async {
    if (_semesters == null || _semesters!.isEmpty) return;
    // Получаем список уникальных годов
    final years = _semesters!.map((s) => s.year).toSet().toList()..sort();
    // Если выбранного семестра ещё нет, используем первый год из списка
    String dialogYear = _selectedSemester?.year ?? years.first;
    // Получаем периоды для выбранного года
    List<int> periodsForYear = _semesters!
        .where((s) => s.year == dialogYear)
        .map((s) => s.period)
        .toSet()
        .toList()
      ..sort();

    // Если не найден период для выбранного года – задаём первый доступный период из общего списка
    int dialogPeriod = periodsForYear.isNotEmpty ? periodsForYear.first : 1;

    final result = await showDialog<Semester>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Выберите период'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Год',
                      border: OutlineInputBorder(),
                    ),
                    value: dialogYear,
                    items: years
                        .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    ))
                        .toList(),
                    onChanged: (newYear) {
                      if (newYear == null) return;
                      setStateDialog(() {
                        dialogYear = newYear;
                        // Обновляем список периодов для выбранного года
                        periodsForYear = _semesters!
                            .where((s) => s.year == dialogYear)
                            .map((s) => s.period)
                            .toSet()
                            .toList()
                          ..sort();
                        dialogPeriod =
                        periodsForYear.isNotEmpty ? periodsForYear.first : 1;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Семестр',
                      border: OutlineInputBorder(),
                    ),
                    value: dialogPeriod,
                    items: periodsForYear
                        .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('Семестр $p'),
                    ))
                        .toList(),
                    onChanged: (newPeriod) {
                      if (newPeriod == null) return;
                      setStateDialog(() {
                        dialogPeriod = newPeriod;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Отмена'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('ОК'),
              onPressed: () {
                // Ищем подходящий семестр по выбранным параметрам
                final newSemester = _semesters!.firstWhere(
                        (s) => s.year == dialogYear && s.period == dialogPeriod,
                    orElse: () => _semesters!.first);
                Navigator.pop(context, newSemester);
              },
            ),
          ],
        );
      },
    );
    if (result != null) {
      _onSemesterChanged(result);
    }
  }

  // Обновляем данные при выборе нового семестра
  void _onSemesterChanged(Semester newSemester) {
    setState(() {
      _selectedSemester = newSemester;
      _futureSemester = dataApi.getStudentSemesterYearPeriod(
        _authHeader,
        newSemester.year,
        newSemester.period,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        //backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        title: const Text('Дисциплины'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showSemesterDialog,
          ),
        ],
      ),
      body: _futureSemester == null
          ? const Center()
          : FutureBuilder<StudentSemester>(
        future: _futureSemester,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка загрузки данных: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Нет данных'));
          }

          final studentSemester = snapshot.data!;
          final List<RecordBook> recordBooks = studentSemester.recordBooks;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                // Заголовок с выбранным периодом
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.deepPurple.shade50,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Года: ${_selectedSemester?.year ?? ''} | Семестр: ${_selectedSemester?.period ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Список факультетов и дисциплин
                for (var recordBook in recordBooks) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.deepPurple.shade100,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        recordBook.faculty,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  for (var discipline in recordBook.discipline)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.deepPurple.shade200,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: ListTile(
                        title: Text(
                          discipline.title,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagesDisciplineScreen(
                                idDiscipline: discipline.id,
                                title: discipline.title,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
