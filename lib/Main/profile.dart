import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Fragments/news_fragment.dart';         // Экран "Новости"
import '../Fragments/objects_fragment.dart';        // Экран "Дисциплины"
import '../Fragments/schedule_fragment.dart';       // Экран "Расписание"
import '../Fragments/messages_fragment.dart';       // Экран "Сообщения"
import '../Fragments/home_fragment.dart';           // Экран профиля, например
import '../Token/SharedPrefManager.dart';
import '../Users/User.dart';
import 'main.dart';         // Модель пользователя
// Импорт экрана игры
import '../GAME/game.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Индекс текущей выбранной страницы для нижнего навигационного меню
  int _currentIndex = 0;
  bool _isLoading = false;
  final List<Widget> _pages = const [
    NewsScreen(),
    ObjectsScreen(),
    ScheduleScreen(),
    MessagesScreen(),
  ];
  User? _user;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    final manager = SharedPrefManager();
    final refreshToken = manager.getRefreshToken();
    if (refreshToken != null) {
      manager.updateToken(refreshToken);
    }
    _user = manager.getUserData();
  }

  /// Универсальная функция воспроизведения звука.
  /// Если fileName не указан, по умолчанию будет воспроизводиться "test12.mp3".
  /// Для swap_menu.mp3 звук прерывается и запускается заново.
  Future<void> _playSound([String fileName = 'test12.mp3']) async {
    final manager = SharedPrefManager();
    if (!manager.getExtremeBetaEnabled()) return;
    if (fileName == 'swap_menu.mp3') {
      await _audioPlayer.stop();
    }
    await _audioPlayer.play(AssetSource(fileName));
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      // При смене вкладки воспроизводим звук swap_menu.mp3
      _playSound('swap_menu.mp3');
      setState(() {
        _isLoading = true;
        _currentIndex = index;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _logout() async {
    final manager = SharedPrefManager();
    await manager.clearTokens();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы вышли из системы')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? formattedDate;
    if (_user != null && _user!.birthDate.isNotEmpty) {
      DateTime date = DateTime.parse(_user!.birthDate);
      formattedDate = DateFormat('dd.MM.yyyy').format(date);
    }
    final manager = SharedPrefManager();

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_user?.fio ?? 'Имя Фамилия'),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
              decoration: const BoxDecoration(color: Colors.purple),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Выход'),
              onTap: () async {
                Navigator.pop(context);
                // Сначала проигрываем test12.mp3 (звук при появлении уведомления)
                await _playSound('test12.mp3');
                // Затем показываем диалог подтверждения выхода
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Подтверждение'),
                      content: const Text('Вы действительно хотите выйти?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Выйти'),
                        ),
                      ],
                    );
                  },
                );
                await _audioPlayer.stop();
                if (shouldLogout == true) {
                  // При подтверждении выхода воспроизводим звук exit.mp3 и выполняем выход
                  await _playSound('exit.mp3');
                  await _logout();
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
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
          _pages[_currentIndex],
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Новости'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Дисциплины'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Расписание'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Сообщения'),
        ],
      ),
    );
  }
}

// Экран настроек
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _soundEnabled = false; // extreme beta
  bool _darkThemeEnabled = false;

  final SharedPrefManager _manager = SharedPrefManager();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = _manager.getNotificationsEnabled();
    _soundEnabled = _manager.getExtremeBetaEnabled();
    _darkThemeEnabled = _manager.getDarkThemeEnabled();
    _initializeNotifications();
  }

  // Инициализация плагина уведомлений
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Универсальная функция воспроизведения звука.
  /// Если fileName не указан, проигрывается test12.mp3.
  Future<void> _playSound([String fileName = 'test12.mp3']) async {
    if (_manager.getExtremeBetaEnabled()) {
      await _audioPlayer.play(AssetSource(fileName));
    }
  }

  // Запрос разрешения на уведомления и показ уведомления
  Future<void> _requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Разрешение на уведомления не предоставлено')),
      );
    } else {
      // Если разрешение получено, показываем уведомление
      await _showNotification();
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Уведомление',
      'Теперь Вы будете получать уведомления',
      platformChannelSpecifics,
    );
  }

  // Обновление темы приложения (реализуйте данную функцию в основном виджете, например через Provider)
  void _updateAppTheme() {
    // Пример: MyApp.of(context).updateTheme(_darkThemeEnabled ? ThemeMode.dark : ThemeMode.light);
    // Здесь необходимо реализовать логику обновления темы вашего приложения.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Включение уведомлений'),
            value: _notificationsEnabled,
            onChanged: (bool value) async {
              setState(() {
                _notificationsEnabled = value;
              });
              await _manager.saveNotificationsEnabled(value);
              if (value) {
                await _requestNotificationPermission();
                // При включении уведомлений воспроизводим звук sms.mp3
                await _playSound('sms.mp3');
              }
            },
          ),
          SwitchListTile(
            title: const Text('Функция звуки (extreme beta)'),
            value: _soundEnabled,
            onChanged: (bool value) async {
              setState(() {
                _soundEnabled = value;
              });
              await _manager.saveExtremeBetaEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: _darkThemeEnabled,
            onChanged: (bool value) async {
              setState(() {
                _darkThemeEnabled = value;
              });
              await _manager.saveDarkThemeEnabled(value);
              _updateAppTheme();
            },
          ),
          const SizedBox(height: 20),
          // Кнопка "Играть (fine test)" для перехода на экран game.dart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Text('Играть (fine test)'),
            ),
          ),
        ],
      ),
    );
  }
}
