import 'package:test/test.dart';
import '../lib/src/grammar.dart';
import 'package:petitparser/petitparser.dart';
import 'test_util.dart';

void main() {
  group('extensions', () {
    group('necessarilyseparatedby', () {
      test('a,a without seps', () {
        castAndCheck<Success>(
            char('a')
                .necessarilySeparatedBy(char(','), includeSeparators: false)
                .parse('a,a'), (result) {
          expect(result.value, equals(['a', 'a']));
        });
      });
      test('just a fails', () {});
      test('a,a with seps', () {
        castAndCheck<Success>(
            char('a')
                .necessarilySeparatedBy(char(','), includeSeparators: true)
                .parse('a,a'), (result) {
          expect(result.value, equals(['a', ',', 'a']));
        });
      });
      test('a,a, without trailing flag', () {});
      test('a,a, with trailing flag', () {});
      test('a,b failure', () {});
    });
  });
}
