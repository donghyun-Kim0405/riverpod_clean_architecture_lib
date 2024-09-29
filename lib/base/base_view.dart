

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_clean_architecture_lib/base/widgets/loading.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';
import '../enums/page_state.dart';
import 'base_controller.dart';


abstract class BaseView<T extends BaseController> extends ConsumerWidget {

  final AutoDisposeStateNotifierProvider? controllerProvider;

  final StateNotifierProvider? aliveControllerProvider;

  BaseView({super.key, this.controllerProvider, this.aliveControllerProvider});

  Widget body(BuildContext context);

  final GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  final Logger logger = RiverpodCleanArchitecture.logger;

  late BuildContext mContext;

  late T c; // controller

  dynamic get s;  // controller.state getter

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    mContext = context;

    if(aliveControllerProvider != null) {
      c = ref.read(aliveControllerProvider!.notifier) as T;
      ref.watch(aliveControllerProvider!);
    } else if(controllerProvider != null){
      c = ref.read(controllerProvider!.notifier) as T;
      ref.watch(controllerProvider!);
    }

    return GestureDetector(
      child: Stack(
        children: [
          annotatedRegion(context),
          c.pageState == PageState.LOADING
              ? _showLoading()
              : Container(),
          Container(),
        ],
      ),
    );
  }

  Widget annotatedRegion(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        //Status bar color for android
        statusBarColor: setStatusBarColor() ?? RiverpodCleanArchitecture.ui.mainBackgroundColor,
        statusBarIconBrightness: RiverpodCleanArchitecture.ui.statusBarIconBrightness ? Brightness.dark : Brightness.light,
      ),
      child: Material(
        color: RiverpodCleanArchitecture.ui.mainBackgroundColor,
        child: pageScaffold(context),
      ),
    );
  }

  Widget pageScaffold(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset(),
      backgroundColor: RiverpodCleanArchitecture.ui.mainBackgroundColor,
      floatingActionButton: floatingActionButton(),
      appBar: appBar(),
      body: pageContent(context),
      bottomNavigationBar: bottomNavigationBar(),
      drawer: drawer(),
    );
  }

  Widget pageContent(BuildContext context) {
    return SafeArea(
      child: body(context),
    );
  }

  Widget showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    return Container();
  }



  Color? setStatusBarColor() {
    return null;
  }

  Widget? floatingActionButton() {
    return null;
  }

  PreferredSizeWidget? appBar() {
    return null;
  }

  bool resizeToAvoidBottomInset() {
    return false;
  }

  Widget? bottomNavigationBar() {
    return null;
  }

  Widget? drawer() {
    return null;
  }

  Widget _showLoading() {
    return const Loading();
  }
}
