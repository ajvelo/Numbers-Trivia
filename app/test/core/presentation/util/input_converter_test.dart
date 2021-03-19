import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbers_trivia/core/error/failures.dart';
import 'package:numbers_trivia/core/presentation/util/input_converter.dart';

void main() {
  InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
        'should return an integer when the string represents an unsigned integer',
        () async {
      // Arrange
      final str = '123';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, Right(123));
    });

    test('should return a Failure when the string is not an unsigned integer',
        () async {
      // Arrange
      final str = 'abc';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, Left(InvalidInputFailure()));
    });

    test('should return a Failure when the string is a negative integer',
        () async {
      // Arrange
      final str = '-123';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, Left(InvalidInputFailure()));
    });
  });
}
