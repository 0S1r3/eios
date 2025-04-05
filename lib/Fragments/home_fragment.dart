import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Users/User.dart';
import '../Token/SharedPrefManager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Флаги для отслеживания состояния каждой кнопки (свернута/развернута)
  bool isExpanded1 = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;
  bool isExpanded4 = false;
  bool isExpanded5 = false;

  // Данные пользователя (их можно получать через SharedPreferences или API)
  User? userData;

  @override
  void initState() {
    super.initState();
    final manager = SharedPrefManager();
    // Обновляем токен, как в оригинале
    manager.updateToken(manager.getRefreshToken().toString());
    // Загружаем данные пользователя
    userData = manager.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    // Форматирование даты рождения
    String formattedDate = '';
    if (userData != null && userData!.birthDate.isNotEmpty) {
      // Предполагаем, что дата хранится в ISO-формате (yyyy-MM-dd'T'HH:mm:ss)
      DateTime date = DateTime.parse(userData!.birthDate);
      formattedDate = DateFormat('dd.MM.yyyy').format(date);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Домашний экран'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Отображение аватара пользователя
            CircleAvatar(
              radius: 50,
              backgroundImage: userData?.photo.urlMedium != null
                  ? NetworkImage(userData!.photo.urlMedium)
                  : const AssetImage('assets/noavatar.png') as ImageProvider,
            ),
            const SizedBox(height: 16),
            // ФИО пользователя
            Text(
              userData?.fio ?? 'Имя пользователя',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // ID студента
            Text(
              'ID: ${userData?.studentCod ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Дата рождения
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Кнопки с переключающимися иконками
            buildToggleButton(
              title: 'Документ 1',
              isExpanded: isExpanded1,
              onPressed: () {
                setState(() {
                  isExpanded1 = !isExpanded1;
                });
              },
            ),
            buildToggleButton(
              title: 'Документ 2',
              isExpanded: isExpanded2,
              onPressed: () {
                setState(() {
                  isExpanded2 = !isExpanded2;
                });
              },
            ),
            buildToggleButton(
              title: 'Документ 3',
              isExpanded: isExpanded3,
              onPressed: () {
                setState(() {
                  isExpanded3 = !isExpanded3;
                });
              },
            ),
            buildToggleButton(
              title: 'Документ 4',
              isExpanded: isExpanded4,
              onPressed: () {
                setState(() {
                  isExpanded4 = !isExpanded4;
                });
              },
            ),
            buildToggleButton(
              title: 'Документ 5',
              isExpanded: isExpanded5,
              onPressed: () {
                setState(() {
                  isExpanded5 = !isExpanded5;
                });
              },
            ),
            // Индикатор загрузки скрыт, поскольку он не используется после загрузки
          ],
        ),
      ),
    );
  }

  // Виджет для кнопки с переключающейся иконкой
  Widget buildToggleButton({
    required String title,
    required bool isExpanded,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Icon(isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
