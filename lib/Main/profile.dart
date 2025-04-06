import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Fragments/Screens/SettingsScreen.dart';
import '../Fragments/news_fragment.dart';
import '../Fragments/objects_fragment.dart';
import '../Fragments/schedule_fragment.dart';
import '../Fragments/messages_fragment.dart';
import '../Token/SharedPrefManager.dart';
import '../Users/User.dart';
import 'main.dart';

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

  // Если fileName не указан, по умолчанию будет воспроизводиться "test12.mp3".
  // Для swap_menu.mp3 звук прерывается и запускается заново.
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
