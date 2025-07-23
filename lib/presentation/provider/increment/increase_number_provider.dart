import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'increase_number_provider.g.dart';

@riverpod
class IncreaseNumber extends _$IncreaseNumber {
  @override
  int build() {
    return 0;
  }

  void increase() {
    state++;
  }
}
