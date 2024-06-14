part of 'riverpod_clean_architecture_cli.dart';

void generateState(String name) {
  final className = '${name}State';
  final fileName = '${_toSnakeCase(name)}_state.dart';

  final content = '''
class ${className} extends BaseState<${className}> {
  ${className}({
    super.pageState
  });

  @override
  ${className} copyWith({PageState? pageState}) {
    return ${className}(
      pageState: pageState ?? this.pageState
    );
  }
}
''';

  createFile(directoryPath: 'generated', fileName: fileName, content: content);
}

