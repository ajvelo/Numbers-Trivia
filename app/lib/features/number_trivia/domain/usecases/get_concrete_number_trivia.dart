import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:numbers_trivia/core/error/failures.dart';
import 'package:numbers_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:numbers_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia {
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  Future<Either<Failure, NumberTrivia>> execute({@required int number}) async {
    return await repository.getConcreteNumberTrivia(number);
  }
}
