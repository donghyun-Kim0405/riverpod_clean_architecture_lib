import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';

import '../enums/page_state.dart';
import '../utils/size_util.dart';

///ignore: must_be_immutable
class PagingView<T> extends StatelessWidget {

  final Future<void> Function() onLoadNextPage;
  final Future<void> Function() onRefresh;
  final List<T> itemList;
  final Widget Function(T item) itemProvider;

  final ScrollController scrollController;
  final String textForEmptyList;
  final PageState pageState;

  PagingView({
    Key? key,
    required this.itemProvider,
    required this.itemList,
    required this.onLoadNextPage,
    required this.onRefresh,
    required this.scrollController,
    required this.textForEmptyList,
    required this.pageState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.depth == 0 && notification.metrics.pixels > notification.metrics.maxScrollExtent) {
            // 바운스가 시작된 시점
            onLoadNextPage();
          }
        }
        return true;
      },
      child: RefreshIndicator(
        color: Colors.white,
        backgroundColor: RiverpodCleanArchitecture.ui.mainBackgroundColor,
        onRefresh: () async => await onRefresh(),
        child: Stack(
          children: [
            Visibility(
              visible: pageState != PageState.LOADING && itemList.isEmpty,
              child: createEmptyScreen(),
            ),
            createListView(),
          ],
        ),
      ),
    );
  }

  Widget createListView() {
    if (itemList.isEmpty || itemList.length == 0) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [],
        controller: scrollController,
      );
    } else {
      return ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (context, index) => itemProvider(itemList[index]),
        physics: const BouncingScrollPhysics(),
        primary: false,
        controller: scrollController,
      );
    }
  }

  Widget createEmptyScreen() => Container(
    width: SizeUtil.deviceSize.width,
    height: SizeUtil.deviceSize.height,
    child: Center(
      child: Text(
        textForEmptyList,
        style: TextStyle(
            fontWeight: FontWeight.w400,
            fontFamily: RiverpodCleanArchitecture.ui.fontFamily,
            fontSize: 18,
            color: Colors.white,
            height: 1.6
          ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
