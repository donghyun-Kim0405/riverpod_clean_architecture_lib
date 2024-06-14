part of 'riverpod_clean_architecture_cli.dart';


void generateUseCase(String name) {
  final className = '${name}UseCase';
  final fileName = '${_toSnakeCase(name)}_use_case.dart';

  final content = '''
import 'package:dartz/dartz.dart';

class ${className}UseCaseParam {
	${className}UseCaseParam();
}

class ${className}UseCaseSuccess extends Success {
	${className}UseCaseSuccess();
}

class ${className}UseCase extends UseCase<${className}UseCaseSuccess, ${className}UseCaseParam> {
	@override
	Future<Either<Failure, ${className}UseCaseSuccess>> call(${className}UseCaseParam params) async {
		
		return Right(${className}UseCaseSuccess());
	}
}

''';

    createFile(directoryPath: 'generated', fileName: fileName, content: content);
}