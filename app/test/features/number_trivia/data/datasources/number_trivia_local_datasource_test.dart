import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:numbers_trivia/core/error/exceptions.dart';
import 'package:numbers_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:numbers_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final testNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      // Arrange
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));

      // Act
      final result = await dataSource.getLastNumberTrivia();

      // Assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(testNumberTriviaModel));
    });

    test('should throw a CacheException when there is not a cached value',
        () async {
      // Arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      // Act
      final call = dataSource.getLastNumberTrivia;

      // Assert
      verifyNever(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(() => call(), throwsA(isInstanceOf<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final testNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test');
    test('should call SharedPreferences to cache the data', () async {
      // Arrange

      // Act
      dataSource.cacheNumberTrivia(triviaToCache: testNumberTriviaModel);

      // Assert
      final exceptedJsonString = json.encode(testNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, exceptedJsonString));
    });
  });
}
