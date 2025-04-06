import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../TimeTable/StudentTimeTable.dart';
import '../Token/SharedPrefManager.dart';
import 'Screens/DisciplineScreen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<StudentTimeTable> _studentTimeTable = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Цвета: для заголовка факультета и карточек занятий
  final Color facultyColor = Colors.deepPurple.shade200;
  final Color lessonColor = Colors.deepPurple.shade100;

  @override
  void initState() {
    super.initState();
    _loadTimeTableForDate(_selectedDate);
  }

  // Загрузка расписания для выбранной даты
  Future<void> _loadTimeTableForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    final formattedDate =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final manager = SharedPrefManager();
    await manager.init();

    try {
      await manager.checkTokenExpiration();
      final token = manager.getAccessToken();
      final authHeader = 'Bearer $token';

      final newTimeTable =
      await manager.dataApi.getStudentTimeTable(authHeader, formattedDate);
      await manager.saveStudentTimeTable(newTimeTable);

      setState(() {
        _studentTimeTable = newTimeTable;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Ошибка загрузки расписания: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Возвращает строку для отображения номера подгруппы
  String _buildSubgroupText(dynamic discipline) {
    if (discipline.subgroupNumber != null) {
      return discipline.subgroupNumber == 0
          ? "Общая дисциплина"
          : "Подгруппа ${discipline.subgroupNumber}";
    }
    return "";
  }

  // Создание строки для отображения дисциплины
  Widget _buildDisciplineRow(dynamic discipline) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisciplineScreen(
              idDiscipline: discipline.id,
              title: discipline.title,
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              discipline.teacher.photo.urlSmall,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discipline.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  discipline.teacher.fio,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "Аудитория ${discipline.auditorium?.number}. корп. ${discipline.auditorium?.campusTitle}",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  _buildSubgroupText(discipline),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Создание Card для временного интервала с одной дисциплиной
  Widget _buildTimeSlotCard(int periodNumber, String time, dynamic discipline) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: lessonColor,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
        child: InkWell(
          onTap: discipline != null
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisciplineScreen(
                  idDiscipline: discipline.id,
                  title: discipline.title,
                ),
              ),
            );
          }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Время проведения пары
                Text(
                  "$periodNumber. $time",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Если есть данные о дисциплине, отображаем их
                if (discipline != null)
                  _buildDisciplineRow(discipline)
                else
                  const Text(
                    "Нет данных",
                    style: TextStyle(color: Colors.black87),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Создание Card для временного интервала с несколькими дисциплинами (например, для разных подгрупп)
  Widget _buildCombinedTimeSlotCard(
      int periodNumber, String time, List disciplines) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: lessonColor,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок времени пары
              Text(
                "$periodNumber. $time",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Column(
                children: List.generate(disciplines.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index < disciplines.length - 1 ? 8.0 : 0),
                    child: _buildDisciplineRow(disciplines[index]),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Создание виджетов расписания для каждого факультета и для каждой пары
  Widget _buildTimeTable() {
    if (_studentTimeTable.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: const Text(
          "Расписание отсутствует",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    // Временные интервалы пар
    final List<String> times = [
      "8:00 - 9:30",
      "9:45 - 11:15",
      "11:35 - 13:05",
      "13:20 - 14:50",
      "15:00 - 16:30",
      "16:40 - 18:10",
      "18:15 - 19:45",
      "19:50 - 21:20"
    ];

    List<Widget> scheduleWidgets = [];

    for (var studentTT in _studentTimeTable) {

      // Заголовок факультета
      scheduleWidgets.add(
        Card(
          color: lessonColor,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 5.0),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              studentTT.facultyName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );

      final lessons = studentTT.timeTable.lessons;
      int lessonIndex = 0;
      // Для каждой пары
      for (int i = 0; i < times.length; i++) {
        if (lessonIndex < lessons.length &&
            lessons[lessonIndex].number == (i + 1)) {
          final lesson = lessons[lessonIndex];
          // Если в одной паре несколько дисциплин – объединяем их в один Card
          if (lesson.disciplines.length > 1) {
            scheduleWidgets.add(
              _buildCombinedTimeSlotCard(i + 1, times[i], lesson.disciplines),
            );
          } else {
            scheduleWidgets.add(
              _buildTimeSlotCard(i + 1, times[i], lesson.disciplines[0]),
            );
          }
          lessonIndex++;
        } else {
          // Если для данного интервала нет дисциплин, создаём Card с сообщением «Нет данных»
          scheduleWidgets.add(
            _buildTimeSlotCard(i + 1, times[i], null),
          );
        }
      }
    }
    return Column(children: scheduleWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание"),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ru_RU',
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _selectedDate,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.week: 'Неделя',
              CalendarFormat.month: 'Месяц',
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              _loadTimeTableForDate(selectedDay);
            },
          ),
          // Отображение расписания
          Expanded(
            child: _isLoading
                ? const Center()
                : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: _buildTimeTable(),
            ),
          ),
        ],
      ),
    );
  }
}
