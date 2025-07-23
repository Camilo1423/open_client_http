import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
part 'hello_world_provider.g.dart';

@riverpod
String helloWorld(Ref ref) {
  return 'Hello World';
}
