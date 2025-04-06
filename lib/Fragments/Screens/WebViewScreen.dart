import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = false;
  File? downloadedFile;
  late String fileExtension;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    setState(() {
      isLoading = true;
    });
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();

      // Скачиваем файл как байты
      final response = await dio.get(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Определяем MIME-тип из заголовков ответа
      final contentType = response.headers.value('content-type') ?? '';
      String ext = '';

      if (contentType.contains('pdf')) {
        ext = 'pdf';
      } else if (contentType.contains('msword') ||
          contentType.contains('officedocument.wordprocessingml.document')) {
        ext = 'docx';
      } else if (contentType.contains('image/jpeg')) {
        ext = 'jpg';
      } else if (contentType.contains('image/png')) {
        ext = 'png';
      } else if (contentType.contains('image/gif')) {
        ext = 'gif';
      } else {
        // Если MIME-тип не определён, пытаемся извлечь из URL
        ext = widget.url.split('.').last.toLowerCase();
      }
      fileExtension = ext;

      final fileName = 'downloaded_file.$ext';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(response.data);
      downloadedFile = file;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки файла: $e')),
      );
    }
  }

  /// Открытие ссылки во внешнем браузере для скачивания файла.
  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку в браузере')),
      );
    }
  }

  /// Возвращает виджет предпросмотра
  Widget _buildPreview() {
    // PDF
    if (fileExtension == 'pdf') {
      if (downloadedFile != null) {
        return PDFView(
          filePath: downloadedFile!.path,
          enableSwipe: true,
          swipeHorizontal: false,
          // Чтобы страницы занимали максимум доступного пространства
          fitEachPage: true,
          fitPolicy: FitPolicy.BOTH,
          // Отключаем автоматические отступы между страницами
          autoSpacing: false,
          // Переход на следующую страницу при «смахивании»
          pageFling: true,
          // При необходимости, чтобы страницы были строго по ширине:
          // fitPolicy: FitPolicy.WIDTH,
        );
      } else {
        return const Center(child: Text('PDF не загружен'));
      }
    }

    // Изображения
    if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
      if (downloadedFile != null) {
        return InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(
            downloadedFile!,
            fit: BoxFit.contain,
          ),
        );
      } else {
        return const Center(child: Text('Изображение не загружено'));
      }
    }

    // Word
    if (fileExtension == 'doc' || fileExtension == 'docx') {
      return const Center(
        child: Text(
          'Предпросмотр документов Word не поддерживается.\n'
              'Пожалуйста, скачайте файл для просмотра.',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Остальные форматы
    return const Center(
      child: Text('Предпросмотр данного формата не поддерживается'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Предпросмотр файла'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _openInBrowser,
            tooltip: 'Скачать файл через браузер',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPreview(),
    );
  }
}
