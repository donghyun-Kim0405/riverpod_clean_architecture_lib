import 'package:flutter/material.dart';

import '../../riverpod_cleanarchitecture.dart';
import 'elevated_container.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedContainer(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          color: RiverpodCleanArchitecture.ui.primaryColor,
        ),
      ),
    );
  }
}
