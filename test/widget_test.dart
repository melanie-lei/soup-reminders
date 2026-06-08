// Smoke test for the app shell. The real UI (and its tests) will replace this
// once the Figma designs land.

import 'package:flutter_test/flutter_test.dart';

import 'package:soup_reminders/features/alarm/alarm_calculator.dart';
import 'package:soup_reminders/features/alarm/models/alarm_models.dart';

void main() {
  group('AlarmCalculator', () {
    const calc = AlarmCalculator();

    test('matches the spec example (leave 09:30, makeup +25)', () {
      final result = calc.compute(
        anchorTime: DateTime(2026, 6, 6, 9, 30),
        activityMinutes: 25, // makeup
        baseBufferMinutes: 30,
        snoozeWindowMinutes: 20,
      );

      expect(result.outOfBedTime, DateTime(2026, 6, 6, 8, 35));
      expect(result.firstRingTime, DateTime(2026, 6, 6, 8, 15));
      expect(result.prepMinutes, 55);
    });

    test('sums enabled question minutes from the library', () {
      final library = [
        AlarmQuestion(id: 'a', label: 'makeup', addedMinutes: 25),
        AlarmQuestion(id: 'b', label: 'lunch', addedMinutes: 15),
        AlarmQuestion(id: 'c', label: 'prep', addedMinutes: 10),
      ];

      final minutes = calc.activityMinutes(
        enabledIds: ['a', 'c'],
        questionLibrary: library,
      );

      expect(minutes, 35);
    });
  });
}
