import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../config/env_config.dart';
import '../models/activity_model.dart';

class AiService {
  static const _uuid = Uuid();
  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// Returns AI-generated age-appropriate activities, falling back to
  /// hardcoded list if the API call fails.
  Future<List<ActivityModel>> getActivitiesForAge(int ageMonths) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': EnvConfig.openRouterModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a child development expert. Return ONLY a valid JSON array of activities. No explanation, no markdown.',
            },
            {
              'role': 'user',
              'content':
                  'Generate 5 age-appropriate developmental activities for a $ageMonths-month-old child. '
                  'Return a JSON array where each object has: title (string), description (string), '
                  'category (one of: Motor, Language, Social, Cognitive), durationMinutes (number), '
                  'materials (array of strings), benefits (array of strings).',
            },
          ],
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            (data['choices'] as List)[0]['message']['content'] as String;
        final cleaned =
            content.trim().replaceAll('```json', '').replaceAll('```', '').trim();
        return (jsonDecode(cleaned) as List)
            .map((item) => ActivityModel(
                  id: _uuid.v4(),
                  title: item['title'] as String,
                  description: item['description'] as String,
                  ageMinMonths: ageMonths > 2 ? ageMonths - 2 : 0,
                  ageMaxMonths: ageMonths + 2,
                  category: item['category'] as String,
                  durationMinutes: (item['durationMinutes'] as num).toInt(),
                  materials: List<String>.from(item['materials'] as List),
                  benefits: List<String>.from(item['benefits'] as List),
                ))
            .toList();
      }
    } catch (_) {}
    return _fallback(ageMonths);
  }

  /// Returns AI-suggested next milestones for a child based on their age and
  /// recent milestone history. Falls back to generic suggestions on error.
  Future<List<String>> generateMilestoneSuggestions({
    required String childName,
    required int ageMonths,
    required List<String> recentMilestones,
  }) async {
    try {
      final milestonesText = recentMilestones.isEmpty
          ? 'No milestones recorded yet.'
          : recentMilestones.join(', ');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': EnvConfig.openRouterModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a child development expert. Return ONLY a valid JSON array of strings. No explanation, no markdown.',
            },
            {
              'role': 'user',
              'content':
                  '$childName is $ageMonths months old. Recent milestones: $milestonesText. '
                  'Suggest 4 developmental milestones to watch for next. Return a JSON array of short milestone titles.',
            },
          ],
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            (data['choices'] as List)[0]['message']['content'] as String;
        final cleaned =
            content.trim().replaceAll('```json', '').replaceAll('```', '').trim();
        return List<String>.from(jsonDecode(cleaned) as List);
      }
    } catch (_) {}
    return ['First steps', 'First words', 'Pincer grasp', 'Wave goodbye'];
  }

  List<ActivityModel> _fallback(int ageMonths) {
    return _hardcoded()
        .where((a) => ageMonths >= a.ageMinMonths && ageMonths <= a.ageMaxMonths)
        .toList();
  }

  List<ActivityModel> _hardcoded() => [
        ActivityModel(id: _uuid.v4(), title: 'Tummy Time', description: 'Place baby on tummy for 2–3 minutes to strengthen neck muscles.', ageMinMonths: 0, ageMaxMonths: 6, category: 'Motor', durationMinutes: 10, materials: ['Play mat'], benefits: ['Neck strength', 'Prevents flat head']),
        ActivityModel(id: _uuid.v4(), title: 'High-Contrast Card Gazing', description: 'Show black-and-white patterns 20–30 cm from face.', ageMinMonths: 0, ageMaxMonths: 3, category: 'Cognitive', durationMinutes: 5, materials: ['High-contrast cards'], benefits: ['Visual development', 'Focus']),
        ActivityModel(id: _uuid.v4(), title: 'Talking and Singing', description: 'Narrate daily activities and sing nursery rhymes.', ageMinMonths: 0, ageMaxMonths: 6, category: 'Language', durationMinutes: 20, materials: [], benefits: ['Language foundation', 'Bonding']),
        ActivityModel(id: _uuid.v4(), title: 'Peekaboo', description: 'Cover your face then reveal with "Peekaboo!"', ageMinMonths: 3, ageMaxMonths: 9, category: 'Social', durationMinutes: 10, materials: [], benefits: ['Object permanence', 'Social bonding']),
        ActivityModel(id: _uuid.v4(), title: 'Water Play', description: 'Let baby splash and explore during bath time.', ageMinMonths: 3, ageMaxMonths: 9, category: 'Cognitive', durationMinutes: 15, materials: ['Bath toys'], benefits: ['Sensory exploration']),
        ActivityModel(id: _uuid.v4(), title: 'Stacking Cups', description: 'Show how to stack and knock down colourful cups.', ageMinMonths: 6, ageMaxMonths: 12, category: 'Cognitive', durationMinutes: 20, materials: ['Stacking cups'], benefits: ['Problem solving', 'Fine motor']),
        ActivityModel(id: _uuid.v4(), title: 'Simple Ball Roll', description: 'Roll a soft ball between you and your baby.', ageMinMonths: 8, ageMaxMonths: 12, category: 'Social', durationMinutes: 15, materials: ['Soft ball'], benefits: ['Turn-taking', 'Coordination']),
        ActivityModel(id: _uuid.v4(), title: 'Shape Sorter', description: 'Introduce a shape sorter with 3–4 basic shapes.', ageMinMonths: 12, ageMaxMonths: 24, category: 'Cognitive', durationMinutes: 20, materials: ['Shape sorter'], benefits: ['Shape recognition', 'Problem solving']),
        ActivityModel(id: _uuid.v4(), title: 'Dance Party', description: 'Dance to upbeat children\'s songs together!', ageMinMonths: 12, ageMaxMonths: 36, category: 'Motor', durationMinutes: 20, materials: ['Music'], benefits: ['Coordination', 'Rhythm']),
        ActivityModel(id: _uuid.v4(), title: 'Puzzle Time', description: 'Large 4–6 piece wooden puzzles.', ageMinMonths: 24, ageMaxMonths: 36, category: 'Cognitive', durationMinutes: 20, materials: ['Wooden puzzle'], benefits: ['Spatial reasoning', 'Problem solving']),
        ActivityModel(id: _uuid.v4(), title: 'Simple Baking', description: 'Let your child help measure and stir.', ageMinMonths: 36, ageMaxMonths: 60, category: 'Cognitive', durationMinutes: 45, materials: ['Baking ingredients'], benefits: ['Maths concepts', 'Independence']),
        ActivityModel(id: _uuid.v4(), title: 'Building Challenges', description: 'Build towers and bridges with blocks.', ageMinMonths: 36, ageMaxMonths: 60, category: 'Cognitive', durationMinutes: 30, materials: ['Blocks'], benefits: ['Engineering thinking', 'Creativity']),
      ];
}
