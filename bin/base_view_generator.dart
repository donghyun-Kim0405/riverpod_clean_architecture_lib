part of 'riverpod_clean_architecture_cli.dart';

void generateView(String name) {
  final className = '${name}View';
  final fileName = '${_toSnakeCase(name)}_view.dart';

  final content = '''
class ${className} extends BaseView<${name}Controller> {
  ${className}({super.key, required super.controllerProvider});

  @override
  ${name}State get s => c.state;

  @override
  Widget body(BuildContext context) {
    return Container();
  }
}
''';

  createFile(directoryPath: 'generated', fileName: fileName, content: content);

}
