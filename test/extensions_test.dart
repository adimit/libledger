import 'package:test/test.dart';
import '../lib/src/grammar.dart';

void main() {
  group('necessarilyseparatedby', () {
    test('a,a without seps', () {});
    test('a,a with seps', () {});
    test('a,a, without trailing flag', () {});
    test('a,a, with trailing flag', () {});
    test('a,b failure', () {});
  });
}
