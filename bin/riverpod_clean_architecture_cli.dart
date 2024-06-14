import 'package:args/args.dart';
import 'dart:io';

part 'base_view_generator.dart';
part 'base_controller_generator.dart';
part 'base_state_generator.dart';
part 'usecase_generator.dart';


void main(List<String> arguments) {
  handleCommand(arguments);
}

void handleCommand(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('g')
    ..addOption('type', abbr: 't', help: 'Type of the file to generate')
    ..addOption('name', abbr: 'n', help: 'Name of the file to generate');

  final argResults = parser.parse(arguments);

  if (argResults.command == null || argResults.command!.name != 'g') {
    print('Usage: riverpod_clean_architecture_cli g --type <type> --name <name>');
    return;
  }

  final type = argResults['type'] as String?;
  final name = argResults['name'] as String?;

  if (type == 'view' && name != null) {
    generateView(name);
  } else if (type == 'co' && name != null) {
    generateController(name);
  } else if (type == 'state' && name != null) {
    generateState(name);
  } else if(type == 'mo' && name != null){
    generateView(name);
    generateController(name);
    generateState(name);
  } else if(type =='usecase' && name !=null) {
    generateUseCase(name);
  }
}


String _toSnakeCase(String input) {
  final buffer = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    if (i > 0 && input[i].toUpperCase() == input[i] && input[i - 1].toLowerCase() == input[i - 1]) {
      buffer.write('_');
    }
    buffer.write(input[i].toLowerCase());
  }
  return buffer.toString();
}

void createFile({required String directoryPath, required String fileName, required String content}) {
  final directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final file = File('${directory.path}/$fileName');
  file.writeAsStringSync(content);

  print('File $fileName created in ${file.path}');
}
