

import 'custom_exception.dart';

class CustomApiResponseParsingException extends CustomException {
  CustomApiResponseParsingException({super.msgForDev, super.msgForUser, super.stackTrace}) : super();
}