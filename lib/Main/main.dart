import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mrsu/Main/profile.dart';
import 'package:mrsu/Token/SharedPrefManager.dart';
import 'package:mrsu/Token/MRSUApi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Точка входа приложения
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefManager().init();
  await initializeDateFormatting('ru_RU', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ЭИОС',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ru', 'RU'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Экземпляр API для получения токена (https://p.mrsu.ru/)
  late MrsuApi tokenApi;
  // Экземпляр API для остальных запросов (https://papi.mrsu.ru/)
  late MrsuApi dataApi;

  @override
  void initState() {
    super.initState();

    // Если accessToken уже сохранён, сразу переходим в профиль.
    final accessToken = SharedPrefManager().getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Profile()),
        );
      });
    }

    tokenApi = MrsuApi(); // базовый URL: https://p.mrsu.ru/
    dataApi = MrsuApi.withBaseUrl('https://papi.mrsu.ru/'); // базовый URL для остальных запросов
  }

  // Метод авторизации
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Получаем токен с использованием tokenApi
      final userToken = await tokenApi.getToken(username: login, password: password);

      // Сохраняем токены через SharedPrefManager
      await SharedPrefManager().saveTokens(
        userToken.accessToken,
        userToken.refreshToken,
      );

      // Формируем заголовок авторизации для запросов
      final authHeader = 'Bearer ${userToken.accessToken}';

      // Получаем данные пользователя через dataApi (papi.mrsu.ru)
      final user = await dataApi.getUser(authHeader);
      await SharedPrefManager().saveUserData(user);

      // Получаем данные семестра студента через dataApi (papi.mrsu.ru)
      final studentSemester = await dataApi.getStudentSemester(authHeader);
      await SharedPrefManager().saveStudentSemester(studentSemester);

      // Переход на экран профиля
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Profile()),
        );
      }
    } catch (e) {
      debugPrint("Ошибка: ${e.toString()}");
      _showErrorToast("Ошибка при авторизации");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Градиентный фон
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Войти в систему',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _loginController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.login_rounded),
                          labelText: 'Логин',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: 'Пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Войти', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}