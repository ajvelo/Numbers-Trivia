import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:numbers_trivia/core/error/exceptions.dart';
import 'package:numbers_trivia/core/error/failures.dart';
import 'package:numbers_trivia/core/network/network_info.dart';
import 'package:numbers_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:numbers_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:numbers_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:numbers_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:numbers_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repositoryImpl;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final testNumber = 1;
    final testNumberTriviaModel =
        NumberTriviaModel(number: testNumber, text: 'test trivia');
    final NumberTrivia testNumberTrivia = testNumberTriviaModel;

    test('should check if the device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Act
      repositoryImpl.getConcreteNumberTrivia(testNumber);

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is successful ',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => testNumberTriviaModel);
        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(testNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
        expect(result, Right(testNumberTrivia));
      });

      test(
          'should cache the data locally when the call to remote data source is successful ',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => testNumberTriviaModel);
        // Act
        await repositoryImpl.getConcreteNumberTrivia(testNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(
            triviaToCache: testNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());
        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(testNumber);

        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(testNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });
    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => testNumberTriviaModel);
        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(testNumber);

        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Right(testNumberTrivia));
      });

      test('should return CacheFailure when their is no cached data is present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // Act
        final result = await repositoryImpl.getConcreteNumberTrivia(testNumber);

        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final testNumberTriviaModel =
        NumberTriviaModel(number: 123, text: 'test trivia');
    final NumberTrivia testNumberTrivia = testNumberTriviaModel;

    test('should check if the device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // Act
      repositoryImpl.getRandomNumberTrivia();

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is successful ',
          () async {
        // Arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => testNumberTriviaModel);
        // Act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // Assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, Right(testNumberTrivia));
      });

      test(
          'should cache the data locally when the call to remote data source is successful ',
          () async {
        // Arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => testNumberTriviaModel);
        // Act
        await repositoryImpl.getRandomNumberTrivia();

        // Assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(
            triviaToCache: testNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());
        // Act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // Assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });
    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => testNumberTriviaModel);
        // Act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Right(testNumberTrivia));
      });

      test('should return CacheFailure when their is no cached data is present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // Act
        final result = await repositoryImpl.getRandomNumberTrivia();

        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });
}
