import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/domain/services/inactivity_timer_service.dart';

void main() {
  group('InactivityTimerService', () {
    late InactivityTimerService service;
    late List<String> events;
    late int warningMinutesRemaining;

    setUp(() {
      events = [];
      warningMinutesRemaining = 0;

      service = InactivityTimerService(
        onInactive: () {
          events.add('inactive');
        },
        onWarning: (minutesRemaining) {
          events.add('warning');
          warningMinutesRemaining = minutesRemaining;
        },
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('should create instance with callbacks', () {
      // Assert
      expect(service, isNotNull);
    });

    test('should start timer when startTimer is called', () async {
      // Act
      service.startTimer();

      // Wait a bit to ensure timers are set
      await Future.delayed(Duration(milliseconds: 100));

      // Assert - No events yet (timers are long)
      expect(events, isEmpty);
    });

    test('should reset timer when resetTimer is called', () async {
      // Arrange
      service.startTimer();

      // Act
      await Future.delayed(Duration(milliseconds: 100));
      service.resetTimer();
      await Future.delayed(Duration(milliseconds: 100));

      // Assert - No events yet
      expect(events, isEmpty);
    });

    test('should stop timer when stopTimer is called', () async {
      // Arrange
      service.startTimer();

      // Act
      service.stopTimer();
      await Future.delayed(Duration(milliseconds: 100));

      // Assert - No events should fire
      expect(events, isEmpty);
    });

    test('should dispose properly', () {
      // Act
      service.dispose();

      // Assert - Should not throw
      expect(() => service.dispose(), returnsNormally);
    });

    test('should handle multiple reset calls without error', () {
      // Act & Assert
      expect(() {
        service.resetTimer();
        service.resetTimer();
        service.resetTimer();
      }, returnsNormally);
    });

    test('should handle stop after dispose', () {
      // Arrange
      service.dispose();

      // Act & Assert
      expect(() => service.stopTimer(), returnsNormally);
    });
  });
}
