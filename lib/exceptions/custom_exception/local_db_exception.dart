import 'package:flutter/cupertino.dart';

import 'custom_exception.dart';

class LocalDBException extends CustomException {
  LocalDBException({super.msgForDev, super.msgForUser, super.stackTrace});
}

class InsertFailException extends LocalDBException {
  InsertFailException(
      {required String tableName,
      required String errorMsg,
      required StackTrace stackTrace})
      : super(
            msgForDev: "InsertFailException (${tableName}) - ${errorMsg}",
            msgForUser: '내부 저장소에 정보 저장 중 오류가 발생했습니다. 문제가 지속되면 관리자에게 문의하세요.',
            stackTrace: stackTrace);
}

class UpdateFailException extends LocalDBException {
  UpdateFailException(
      {required String tableName,
      required String errorMsg,
      required StackTrace stackTrace})
      : super(
            msgForUser: '내부 저장소 정보 업데이트 중 오류가 발생했습니다. 문제가 지속되면 관리자에게 문의하세요.',
            msgForDev: 'UpdateFailException (${tableName}) - ${errorMsg}',
            stackTrace: stackTrace);
}

class SelectFailException extends LocalDBException {
  SelectFailException(
      {required String tableName,
      required String errorMsg,
      required StackTrace stackTrace})
      : super(
            msgForUser: '내부 저장소 정보 조회 중 오류가 발생했습니다.',
            msgForDev: 'SelectFailException (${tableName}) - ${errorMsg}',
            stackTrace: stackTrace);
}

class DeleteFailException extends LocalDBException {
  DeleteFailException(
      {required String tableName,
      required String errorMsg,
      required StackTrace stackTrace})
      : super(
            msgForUser: '내부 저장소 정보 삭제 중 오류가 발생했습니다.',
            msgForDev: 'DeleteFailException (${tableName}) - ${errorMsg}',
            stackTrace: stackTrace);
}
