import 'package:flutter_riverpod/legacy.dart';

class BottomNavBarProvider extends StateNotifier<int> {
  BottomNavBarProvider() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

final bottomIndexProvider = StateNotifierProvider<BottomNavBarProvider, int>((
  ref,
) {
  return BottomNavBarProvider();
});
