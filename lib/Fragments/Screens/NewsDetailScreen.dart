// Экран с подробной новостью
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../Optional/DateParser.dart';
import '../../System_news/News.dart';
import '../news_fragment.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали новости'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата новости вверху
            Text(
              formatDate(news.date),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Заголовок новости с HTML-разметкой
            Html(
              data: news.header,
              style: {
                "body": Style(
                  fontSize: FontSize(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              },
            ),
            const Divider(),
            // Текст новости (также можно рендерить как HTML)
            Expanded(
              child: SingleChildScrollView(
                child: Html(
                  data: news.text,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      color: Colors.black87,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}