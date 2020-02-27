import 'package:test/test.dart';
import '../lib/src/grammar.dart';
import 'package:petitparser/petitparser.dart';

void main() {
  group('extensions', () {
    group('necessarilyseparatedby', () {
      test('a,a without seps', () {
        final result = char('a')
            .necessarilySeparatedBy(char(','), includeSeparators: false)
            .parse('a,a');

        expect(result, isA<Success>());
        expect((result as Success).value, equals(['a', 'a']));
      });
      test('just a fails', () {});
      test('a,a with seps', () {});
      test('a,a, without trailing flag', () {});
      test('a,a, with trailing flag', () {});
      test('a,b failure', () {});
    });
  });
}
