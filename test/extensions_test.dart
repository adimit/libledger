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
      test('just a fails', () {
        castAndCheck<Failure>(char('a').necessarilySeparatedBy(char(',')));
      });
      test('a,a with seps', () {
        castAndCheck<Success>(
            char('a')
                .necessarilySeparatedBy(char(','), includeSeparators: true)
                .parse('a,a'), (result) {
          expect(result.value, equals(['a', ',', 'a']));
        });
      });
      test('a,a, without trailing flag', () {
        castAndCheck<Failure>(char('a')
            .necessarilySeparatedBy(char(','), optionalSeparatorAtEnd: false));
      });
      test('a,a, with trailing flag', () {
        castAndCheck<Success>(char('a')
            .necessarilySeparatedBy(char(','), optionalSeparatorAtEnd: false));
      });
      test('a,b failure', () {
        castAndCheck<Failure>(char('a')
            .necessarilySeparatedBy(char(',')));
      });
    });
  });
}
