import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../GAME/game.dart';
import '../../Token/SharedPrefManager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _soundEnabled = false; // extreme beta

  final SharedPrefManager _manager = SharedPrefManager();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = _manager.getNotificationsEnabled();
    _soundEnabled = _manager.getExtremeBetaEnabled();
    _initializeNotifications();
  }

  // Инициализация плагина уведомлений
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/bg_icon');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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