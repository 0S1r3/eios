import 'package:flutter/material.dart';
import '../../Events/Events.dart';
import '../../Optional/DateParser.dart';

class EventDetailScreen extends StatelessWidget {
  final Events event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Парсинг и форматирование дат
    final formattedStartDate = formatDate(event.startDate);
    final formattedEndDate = formatDate(event.endDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Даты и время
            Text(
              'Начало: $formattedStartDate ${event.startTime}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Окончание: $formattedEndDate ${event.endTime}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Место проведения
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.place,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ответственный за событие
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text(
                  event.responsible,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Описание события
            const Text(
              'Описание:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (event.techInfo.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Техническая информация:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.techInfo,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
