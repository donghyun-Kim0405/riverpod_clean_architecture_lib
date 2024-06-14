

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';
import 'failure.dart';


abstract class UseCase<Type, Params> {
  Logger logger = RiverpodCleanArchitecture.logger;

  Future<Either<Failure, Type>> call(Params params);

}