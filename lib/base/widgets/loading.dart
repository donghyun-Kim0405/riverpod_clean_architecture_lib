import 'package:flutter/material.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';

import 'elevated_container.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedContainer(
        padding: const EdgeInsets.all(16),
        child: CircularProgressIndicator(
          color: RiverpodCleanArchitecture.ui.progressColor,
        ),
      ),
    );
  }
}
