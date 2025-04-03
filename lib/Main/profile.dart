import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Fragments/news_fragment.dart';         // Экран "Новости"
import '../Fragments/objects_fragment.dart';        // Экран "Дисциплины"
import '../Fragments/schedule_fragment.dart';       // Экран "Расписание"
import '../Fragments/messages_fragment.dart';       // Экран "Сообщения"
import '../Fragments/home_fragment.dart';           // Экран профиля, например
import '../Token/SharedPrefManager.dart';
import '../Users/User.dart';
import 'main.dart';         // Модель пользователя

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Индекс текущей выбранной страницы для нижней навигации
  int _currentIndex = 0;
  // Флаг для отображения индикатора загрузки
  bool _isLoading = false;

  // Список страниц нижней навигации (по порядку: Новости, Дисциплины, Расписание, Сообщения)
  final List<Widget> _pages = const [
    NewsScreen(),
    ObjectsScreen(),
    ScheduleScreen(),
    MessagesScreen(),
  ];

  // Пользовательские данные (могут понадобиться для отображения фото)
  User? _user;

  @override
  void initState() {
    super.initState();
    final manager = SharedPrefManager();
    // Обновляем токен
    manager.updateToken(manager.getRefreshToken().toString());
    // Получаем данные пользователя
    _user = manager.getUserData();
  }

  // Метод обработки выбора пункта нижней навигации
  void _onItemTapped(int index) {
    setState(() {
      if (_currentIndex != index) {
        _isLoading = true;
        _currentIndex = index;
        // Имитация задержки для отображения ProgressIndicator (при необходимости можно убрать)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        _isLoading = false;
      }
    });
  }

  // Метод для обработки выхода: очистка токенов
  Future<void> _logout() async {
    final manager = SharedPrefManager();
    await manager.clearTokens();
    if (mounted) {
      // Показываем уведомление
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы вышли из системы')),
      );

      // Удаляем все предыдущие экраны и переходим на экран логина
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
            (route) => false, // Удаляет все предыдущие экраны
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    String? formattedDate;
    if (_user != null && _user!.birthDate.isNotEmpty) {
      // Предполагаем, что дата хранится в ISO-формате (yyyy-MM-dd'T'HH:mm:ss)
      DateTime date = DateTime.parse(_user!.birthDate);
      formattedDate = DateFormat('dd.MM.yyyy').format(date);
    }

    final AudioPlayer _audioPlayer = AudioPlayer();

    Future<void> _playSound() async {
      await _audioPlayer.play(AssetSource('test12.mp3'));
    }

    return Scaffold(
      // Drawer с меню
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Заголовок Drawer с информацией профиля
            UserAccountsDrawerHeader(
              accountName: Text(_user?.fio ?? 'Имя Фамилия'),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // чтобы Column не занимал лишнее пространство
                children: [
                  Text('ID: ${_user?.studentCod ?? _user?.teacherCod ?? '0'}'),
                  Text('Дата рождения: ${formattedDate ?? 'не указана'}'),
                ],
              ),
              currentAccountPicture: _user != null && _user!.photo.urlSmall.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(_user!.photo.urlSmall),
              )
                  : const CircleAvatar(
                backgroundColor: Colors.purpleAccent,
                child: Icon(Icons.person, size: 40.0, color: Colors.purpleAccent),
              ),
              decoration: const BoxDecoration(
                color: Colors.purple,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Документы'),
              onTap: () {
                Navigator.pop(context);
                // Реализуйте переход на экран "Документы"
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                // Реализуйте переход на экран "Настройки"
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выход'),
              onTap: () async {
                Navigator.pop(context);
                _playSound();
                // Показываем диалог подтверждения выхода
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Подтверждение'),
                      content: const Text('Вы действительно хотите выйти?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Отмена
                          },
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Подтверждение выхода
                          },
                          child: const Text('Выйти'),
                        ),
                      ],
                    );
                  },
                );
                if (shouldLogout == true) {
                  await _logout();
                }
              },
            ),

          ],
        ),
      ),
      appBar: AppBar(
        // Заменяем стандартную иконку меню на аватарку пользователя
        leading: Builder(
          builder: (context) => IconButton(
            icon: _user != null && _user!.photo.urlSmall.isNotEmpty
                ? CircleAvatar(
              backgroundImage: NetworkImage(_user!.photo.urlSmall),
            )
                : const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blueAccent),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // Отображаем выбранную страницу нижней навигации
          _pages[_currentIndex],
          // Если включена загрузка, отображаем индикатор
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Новости',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Дисциплины',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Сообщения',
          ),
        ],
      ),
    );
  }
}
