
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_clean_architecture_lib/exceptions/custom_exception/firestore_exception.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';



/// Firestore 에서 리스트를 조회할때에는 offset를 사용할 수 없습니다. 조회한 마지막 문서 정보 이후로 이어서 정보 조회가 가능합니다.
/// 즉 페이징할 경우 리턴해야하는 값은 두가지 입니다. 1. 결과 리스트, 2. 마지막 문서 정보
/// 이에 따라 결과 리스트를 List<T> 타입으로 리턴하는 것이 아닌
/// Map<결과 리스트, 마지막 문서 정보> 형태로 리턴합니다.
/// 이떄 결과리스트는 items 로 조회하고
/// 마지막 문서 정보는 lastDocument 로 조회합니다.
class ModelPaginatedResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;

  ModelPaginatedResult({
    required this.items,
    required this.lastDocument
  });

  bool get hasMore => lastDocument != null;
}



abstract class FirestoreRepository<T> {

  static const QUERY_RESULTS = "queryResults";
  static const LAST_DOCUMENT = "lastDocument";

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final logger = RiverpodCleanArchitecture.logger;
  final String collectionName;
  final T? Function(Map<String, dynamic>) fromMap;
  CollectionReference get ref => FirebaseFirestore.instance.collection(collectionName);

  FirestoreRepository({required this.collectionName, required this.fromMap});

  /// 컬렉션 내 모든 도큐먼트의 갯수를 리턴합니다.
  Future<int> getCount() async =>
      await ref.count().get().then((AggregateQuerySnapshot snapshot) => snapshot.count ?? 0);

  /// 데이터를 임의로 추가합니다.
  Future<void> createDocument({required Map<String, dynamic> data}) async => await ref
      .add(data)
      .onError((error, stackTrace) {
         throw FirestoreCreateFailException(
           collectionName: collectionName,
             msgForDev: error.toString(),
             stackTrace: stackTrace,
         );
      });

  /// 원하는 Id로 데이터를 저장합니다. 이전에 같은 값의 아이디가 존재했었다면 새로 덮어 씁니다.
  Future<void> createDocumentWithUid({required String uid, required Map<String, dynamic> data}) async => await ref
      .doc(uid)
      .set(data)
      .onError((error, stackTrace) {
        throw FirestoreCreateFailException(
          collectionName: collectionName,
          msgForDev: error.toString(),
          stackTrace: stackTrace,
        );
  });

  /// 찾고자하는 값을 Model로 변환하여 리턴합니다.
  Future<T?> getDocumentById({required String docId}) async {
    DocumentSnapshot doc = await ref
        .doc(docId)
        .get()
        .onError((error, stackTrace) {
          throw FirestoreGetFailException(
              collectionName: collectionName,
              msgForDev: error.toString(),
              stackTrace: stackTrace
          );
    });

    if (doc.exists) {
      logger.i('Document data: ${doc.data()}');
      return fromMap(doc.data() as Map<String, dynamic>);
    } else {
      logger.i('Document not found with id: $docId');
      return null;
    }
  }

  Future<void> updateDocument(String docId, Map<String, dynamic> updatedData) async =>
      await ref
          .doc(docId)
          .update(updatedData)
          .onError((error, stackTrace) {
              throw FirestoreUpdateFailException(
                  collectionName: collectionName,
                  msgForDev: error.toString(),
                  stackTrace: stackTrace
              );
      });

  Future<void> deleteDocument(String docId) async =>
      await ref
          .doc(docId)
          .delete()
          .onError((error, stackTrace) {
            throw FirestoreDeleteFailException(
                collectionName: collectionName,
                msgForDev: error.toString(),
                stackTrace: stackTrace
            );
      });

  Future<Map<String, dynamic>> getAllDocuments() async {
    QuerySnapshot querySnapshot = await ref.get();
    List<T> resultList = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      if (doc.exists) {
        logger.i('Document data: ${doc.data()}');
        var result = fromMap(doc.data() as Map<String, dynamic>);
        if (result != null) resultList.add(result);
      } else {
        logger.i('Document not found or does not exist with id: ${doc.id}');
        // 예외를 던지지 않고 로그만 기록하고 계속 진행
      }
    }

    return {
      QUERY_RESULTS: resultList,
    };
  }


  /// Query와 함께 다수의 문서를 조회합니다. return (문서리스트, 마지막문서)
  Future<ModelPaginatedResult<T>> getDocumentsWithQuery({
    required Query query,
    DocumentSnapshot? startAfterDocument,
    int? limit,
  }) async {

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<T> resultList = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      if (doc.exists) {
        logger.i('Document data: ${doc.data()}');
        var result = fromMap(doc.data() as Map<String, dynamic>);
        if (result != null) resultList.add(result);
      } else {
        logger.i(doc.data().toString());
      }
    }

    // 페이징을 위해 마지막 문서 업데이트
    DocumentSnapshot? lastDocument;
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
    }

    return ModelPaginatedResult(
        items: resultList,
        lastDocument: lastDocument
    );
  }

  /// ----------------------------- 이하 transaction 사용시 ----------------------------------------------------
  /// 위 비슷한 메서드에 param으로 분기하지 않고 의도적으로 따로 분리합니다. 혼선을 방지하기 위해


  /// (Transaction)데이터를 임의로 추가합니다.
  Future<void> createDocumentOnTransaction({required Transaction transaction, required Map<String, dynamic> data}) async => await transaction.set(ref.doc(), data);

  /// (Transaction)데이터를 정해진 아이디로 추가합니다.
  Future<void> createDocumentWithIdOnTransaction({required Transaction transaction, required String docId, required Map<String, dynamic> data}) async => await transaction.set(ref.doc(docId), data);

  /// (Transaction) 데이터를 삭제합니다.
  Future<void> deleteDocumentOnTransaction({required Transaction transaction, required String docId}) async => await transaction.delete(ref.doc(docId));

  /// (Transaction) 찾고자하는 값을 Model로 변환하여 리턴합니다.
  Future<T?> getDocumentByIdOnTraction({required Transaction transaction, required String docId}) async {

    DocumentSnapshot doc = await transaction.get(ref.doc(docId));

    if (doc.exists) {
      logger.i('Document data: ${doc.data()}');
      return fromMap(doc.data() as Map<String, dynamic>);
    } else {
      logger.i(doc.data().toString());
    }
  }

  Future<void> updateDocumentOnTransaction({required Transaction transaction, required String docId, required Map<String, dynamic> updatedData}) async =>
      await transaction.update(ref.doc(docId), updatedData);





}