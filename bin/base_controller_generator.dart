
part of 'riverpod_clean_architecture_cli.dart';

void generateController(String name) {
  final className = '${name}Controller';
  final fileName = '${_toSnakeCase(name)}_controller.dart';

  final content = '''
class ${className} extends BaseController<${name}State> {
  ${className}({required ${name}State state}): super(state);

  @override
  onInit() {
    // TODO: implement onInit
    return super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
''';

  createFile(directoryPath: 'generated', fileName: fileName, content: content);
}
