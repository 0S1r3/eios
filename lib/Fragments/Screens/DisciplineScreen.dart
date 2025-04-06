import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../BRS/StudentRatingPlan/StudentRatingPlan.dart';
import '../../Token/MRSUAPI.dart';
import '../../Token/SharedPrefManager.dart';
import 'WebViewScreen.dart';
import '../../ResourceServer/BRS/Discipline.dart';

class DisciplineScreen extends StatefulWidget {
  final int idDiscipline;
  final String title;

  const DisciplineScreen({
    super.key,
    required this.idDiscipline,
    required this.title,
  });

  @override
  _DisciplineScreenState createState() => _DisciplineScreenState();
}

class _DisciplineScreenState extends State<DisciplineScreen> {
  late Future<StudentRatingPlan> _futureRatingPlan;
  late Future<Discipline> _futureDiscipline;

  final SharedPrefManager _manager = SharedPrefManager();
  late MrsuApi dataApi;
  late String _authHeader;

  // Индекс выбранной вкладки BottomNavigationBar
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/');
    final accessToken = _manager.getAccessToken() ?? '';
    _authHeader = 'Bearer $accessToken';
    _futureRatingPlan =
        dataApi.getStudentRatingPlan(_authHeader, widget.idDiscipline);
    _futureDiscipline =
        dataApi.getDiscipline(_authHeader, widget.idDiscipline);
  }

  // Методы для обновления данных
  void _refreshRatingPlan() {
    setState(() {
      _futureRatingPlan =
          dataApi.getStudentRatingPlan(_authHeader, widget.idDiscipline);
    });
  }

  void _refreshDiscipline() {
    setState(() {
      _futureDiscipline =
          dataApi.getDiscipline(_authHeader, widget.idDiscipline);
    });
  }

  Future<void> _openReport(String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
    );
  }

  Widget _buildRatingPlanContent() {
    return FutureBuilder<StudentRatingPlan>(
      future: _futureRatingPlan,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ошибка загрузки данных: ${snapshot.error}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _refreshRatingPlan,
                  child: const Text("Обновить"),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Нет данных'));
        }

        final plan = snapshot.data!;

        if (plan.sections.isEmpty) {
          return const Center(child: Text('Рейтинг план не заполнен'));
        }

        double totalMark = 0;
        double totalMaxMark = 0;
        List<Widget> sectionsWidgets = [];

        for (var section in plan.sections) {
          List<Widget> controlWidgets = [];
          for (var control in section.controlDots) {
            String formattedDate = "Не указана";
            try {
              DateTime dt = DateTime.parse(control.date);
              formattedDate = DateFormat('dd.MM.yyyy').format(dt);
            } catch (e) {
              // Значение по умолчанию
            }
            double mark =
                double.tryParse(control.mark.ball.toString()) ?? 0;
            double maxMark =
                double.tryParse(control.maxBall.toString()) ?? 0;
            totalMark += mark;
            totalMaxMark += maxMark;

            controlWidgets.add(
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            control.title.trim().isNotEmpty
                                ? control.title.replaceAll("\n", "")
                                : "Контрольная точка не указана",
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Дата сдачи: $formattedDate",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$mark/$maxMark",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (control.report.docFiles.url.isNotEmpty) {
              String reportDate = "Не указана";
              try {
                DateTime reportDt =
                DateTime.parse(control.report.createDate);
                reportDate =
                    DateFormat('dd.MM.yyyy').format(reportDt);
              } catch (e) {
                // Значение по умолчанию
              }

              controlWidgets.add(
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Дата прикрепления отчета: $reportDate",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Файл отчета: ${control.report.docFiles.title}",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _openReport(
                              control.report.docFiles.url);
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Открыть/Скачать файл"),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
          if (controlWidgets.isNotEmpty) {
            controlWidgets[controlWidgets.length - 1] = Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child:
              (controlWidgets.last as Container).child,
            );
          }
          sectionsWidgets.add(
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Text(
                      section.title.trim().isNotEmpty
                          ? section.title.replaceAll("\n", "")
                          : "Наименование раздела не указано",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...controlWidgets,
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              ...sectionsWidgets,
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Оценка за нулевую сессию: ${plan.markZeroSession.ball.toString()}/5.0",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Итого: ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$totalMark/$totalMaxMark",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisciplineContent() {
    return FutureBuilder<Discipline>(
      future: _futureDiscipline,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Ошибка загрузки данных дисциплины: ${snapshot.error}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _refreshDiscipline,
                  child: const Text("Обновить"),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Нет данных о дисциплине'));
        }

        final discipline = snapshot.data!;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Информация по дисциплине",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(
                      bottom: 16),
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow("Год",
                            discipline.year.toString()),
                        _buildDetailRow("Факультет",
                            discipline.faculty),
                        _buildDetailRow("Форма обучения",
                            discipline.educationForm),
                        _buildDetailRow("Уровень образования",
                            discipline.educationLevel),
                        _buildDetailRow("Профиль",
                            discipline.profile),
                        _buildDetailRow("Период",
                            discipline.periodString),
                      ],
                    ),
                  ),
                ),
                Text(
                  "Файлы дисциплины",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                discipline.docFiles.isNotEmpty
                    ? ListView.separated(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount:
                  discipline.docFiles.length,
                  separatorBuilder:
                      (context, index) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final file =
                    discipline.docFiles[index];
                    return Card(
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                            Icons.insert_drive_file,
                            color: Colors.deepPurple),
                        title: Text(file.title),
                        subtitle:
                        Text(file.fileName),
                        trailing: IconButton(
                          icon: Icon(
                              Icons.open_in_new,
                              color:
                              Colors.deepPurple),
                          onPressed: () {
                            _openReport(file.url);
                          },
                        ),
                      ),
                    );
                  },
                )
                    : const Text("Нет файлов дисциплины для отображения."),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(
                label,
                style:
                const TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Выбор содержимого экрана
    Widget bodyContent = _currentIndex == 0
        ? _buildRatingPlanContent()
        : _buildDisciplineContent();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Оценки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Дисциплина',
          ),
        ],
      ),
    );
  }
}
