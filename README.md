
pubspec.yaml

  riverpod_clean_architecture_lib:
    git:
      url: https://github.com/donghyun-Kim0405/riverpod_clean_architecture_lib.git
      ref: master



Firestore Sample 

# Post Repository

```dart 
import 'package:ai_gallery/app/core/base/base_repository.dart';
import 'package:ai_gallery/app/data/query/post_query.dart';
import 'package:ai_gallery/app/enums/firebase_firestore_enum.dart';
import 'package:ai_gallery/app/model/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepository extends BaseRepository<PostModel> {
PostRepository(): super(collectionName: FirestoreCollection.POST, fromDoc: PostModel.fromDoc);

static const String ORDER_BY_LIKE_COUNT = "likeCount";
static const String ORDER_BY_UPDATED = "updatedAt";
static const String ORDER_BY_CREATED = "createdAt";

Future<void> savePostWithUid(PostModel postModel) async =>
await createDocumentWithUid(uid: postModel.docId!, data: postModel.toJson());

Future<Map<String, dynamic>> fetchListWithSort({required DocumentSnapshot? lastDocument, required String orderBy}) async {

    Query query;

    /// 인기순 포함되어야함
    switch(orderBy) {
      case ORDER_BY_UPDATED :
        query = PostQuery.fetchListOrderByUpdatedAt();
        break;
      case ORDER_BY_CREATED :
        query = PostQuery.fetchListOrderByCreatedAt();
        break;
      case ORDER_BY_LIKE_COUNT :
        query = PostQuery.fetchListOrderByLikeCount();
        break;
      default:
        query = PostQuery.fetchListOrderByCreatedAt();
        break;
    }

    return await getDocumentsWithQuery(
        query: query,
        startAfterDocument: lastDocument,
        limit: 20
    );
} //fetchListWithSort()

/// 내가 쓴 게시글
Future<Map<String, dynamic>?> fetchMyPost({required DocumentSnapshot? lastDocument}) async =>
await getDocumentsWithQuery(
query: PostQuery.fetchListByAuthorId(),
limit: 20,
startAfterDocument: lastDocument
);

/// transaction 걸고 postModel가져오기
Future<PostModel?> findPostByIdOnTransaction({required Transaction transaction, required String docId}) async =>
await getDocumentByIdOnTraction(transaction: transaction, docId: docId);

/// 댓글 업데이트
Future<void> updateReplyOnTransaction({required Transaction transaction, required String docId, required List<String> replyIdList}) async =>
await updateDocumentOnTransaction(transaction: transaction, docId: docId, updatedData: {FirebaseFirestoreParams.POST_REPLY_ID_LIST: replyIdList});

/// 좋아요 업데이트
Future<void> updateLikeOnTransaction({required Transaction transaction, required String docId, required List<String> likeUserIdList, required int likeCount}) async =>
await updateDocumentOnTransaction(transaction: transaction, docId: docId, updatedData: {FirebaseFirestoreParams.POST_LIKE_COUNT: likeCount, FirebaseFirestoreParams.POST_LIKE_USER_LIST: likeUserIdList});

}
```

# Post Query

```dart

import 'package:ai_gallery/app/data/api_util/ai_gallery_user_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../enums/firebase_firestore_enum.dart';

abstract class PostQuery {

  static CollectionReference get postCollection =>
      FirebaseFirestore.instance.collection(FirestoreCollection.POST);

  /// 최신 업데이트 순
  static Query fetchListOrderByUpdatedAt() =>
      postCollection
          .orderBy(FirebaseFirestoreParams.POST_UPDATED_AT, descending: true);

  /// 최신 등록 순
  static Query fetchListOrderByCreatedAt() =>
      postCollection
          .orderBy(FirebaseFirestoreParams.POST_CREATED_AT, descending: true);

  /// 인기순 -> 좋아요 갯수 순위
  static Query fetchListOrderByLikeCount() =>
      postCollection
          .orderBy(FirebaseFirestoreParams.POST_LIKE_COUNT, descending: true);

  static Query fetchListByAuthorId() =>
      postCollection
          .where(FirebaseFirestoreParams.POST_AUTHOR_ID, isEqualTo: AiGalleryUserApi.instance.user.uid)
          .orderBy(FirebaseFirestoreParams.POST_UPDATED_AT, descending: true);

}
```