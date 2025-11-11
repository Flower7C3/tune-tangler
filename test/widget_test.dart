import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tune_tangler/adapter/track_audio_source.dart';

void main() {
  group('TuneTangler Basic Tests', () {
    test('TrackAudioSource enum values', () {
      expect(TrackAudioSource.recording, isA<TrackAudioSource>());
      expect(TrackAudioSource.file, isA<TrackAudioSource>());
      expect(TrackAudioSource.values.length, 2);
    });

    test('TrackAudioSourceAdapter type ID', () {
      final adapter = TrackAudioSourceAdapter();
      expect(adapter.typeId, 117);
    });

    test('TrackAudioSource enum comparison', () {
      expect(TrackAudioSource.recording != TrackAudioSource.file, true);
      expect(TrackAudioSource.recording == TrackAudioSource.recording, true);
    });

    test('TrackAudioSource index values', () {
      expect(TrackAudioSource.recording.index, 0);
      expect(TrackAudioSource.file.index, 1);
    });
  });

  group('Widget Tests', () {
    testWidgets('Basic MaterialApp test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Test App'))),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Text widget test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Center(child: Text('Hello World'))),
      );

      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('Button widget test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ElevatedButton(onPressed: null, child: Text('Test Button')),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
