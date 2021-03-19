import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:numbers_trivia/core/error/exceptions.dart';
import 'package:numbers_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:numbers_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpHttpClientFail404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final testNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    final testNumber = 1;
    test('''should perform a GET request on a URL with number being the 
        endpoint and with application/json header''', () async {
      // Arrange
      setUpMockHttpClientSuccess200();

      // Act
      dataSource.getConcreteNumberTrivia(testNumber);

      // Assert
      verify(mockHttpClient.get(Uri.parse('http://numbersapi.com/$testNumber'),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when response code is 200', () async {
      // Arrange
      setUpMockHttpClientSuccess200();

      // Act
      final result = await dataSource.getConcreteNumberTrivia(testNumber);

      // Assert
      expect(result, equals(testNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // Arrange
      setUpHttpClientFail404();

      // Act
      final call = dataSource.getConcreteNumberTrivia;

      // Assert
      expect(() => call(testNumber), throwsA(isInstanceOf<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final testNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perform a GET request on a URL with number being the 
        endpoint and with application/json header''', () async {
      // Arrange
      setUpMockHttpClientSuccess200();

      // Act
      dataSource.getRandomNumberTrivia();

      // Assert
      verify(mockHttpClient.get(Uri.parse('http://numbersapi.com/random'),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when response code is 200', () async {
      // Arrange
      setUpMockHttpClientSuccess200();

      // Act
      final result = await dataSource.getRandomNumberTrivia();

      // Assert
      expect(result, equals(testNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      // Arrange
      setUpHttpClientFail404();

      // Act
      final call = dataSource.getRandomNumberTrivia;

      // Assert
      expect(() => call(), throwsA(isInstanceOf<ServerException>()));
    });
  });
}
