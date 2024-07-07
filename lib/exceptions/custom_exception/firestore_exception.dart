
import 'package:riverpod_clean_architecture_lib/exceptions/custom_exception/custom_exception.dart';

class FirestoreException extends CustomException {
  FirestoreException({super.msgForDev, super.msgForUser, super.stackTrace});
}

class FirestoreNotFoundException extends FirestoreException {
  FirestoreNotFoundException({
      required String collectionName,
      required String msgForDev,
      required StackTrace stackTrace,
      String msgForUser = '해당 정보를 찾을 수 없습니다.'
  }) : super(
            msgForDev: "FirestoreNotFoundException (${collectionName}) - ${msgForDev}",
            msgForUser: msgForUser,
            stackTrace: stackTrace
  );
}

class FirestoreGetFailException extends FirestoreException {
  FirestoreGetFailException({
      required String collectionName,
      required String msgForDev,
      required StackTrace stackTrace
  }) : super(
            msgForDev: "FirestoreGetFailException (${collectionName}) - ${msgForDev}",
            msgForUser: '정보를 가져오는데 실패했습니다.',
            stackTrace: stackTrace
  );
}

class FirestoreCreateFailException extends FirestoreException {
  FirestoreCreateFailException({
      required String collectionName,
      required String msgForDev,
      required StackTrace stackTrace,
      String msgForUser = '정보 생성에 실패했습니다.'
  })
      : super(
            msgForDev: "FirestoreCreateFailException (${collectionName}) - ${msgForDev}",
            msgForUser: msgForUser,
            stackTrace: stackTrace
  );
}

class FirestoreUpdateFailException extends FirestoreException {
  FirestoreUpdateFailException(
      {required String collectionName,
      required String msgForDev,
      required StackTrace stackTrace,
      String msgForUser = '정보 수정에 실패했습니다.'})
      : super(
            msgForDev: "FirestoreUpdateFailException (${collectionName}) - ${msgForDev}",
            msgForUser: msgForUser,
            stackTrace: stackTrace
  );
}

class FirestoreDeleteFailException extends FirestoreException {
  FirestoreDeleteFailException(
      {required String collectionName,
      required String msgForDev,
      required StackTrace stackTrace,
      String msgForUser = '정보 삭제에 실패했습니다.'})
      : super(
            msgForDev: "FirestoreDeleteFailException (${collectionName}) - ${msgForDev}",
            msgForUser: msgForUser,
            stackTrace: stackTrace
  );
}

