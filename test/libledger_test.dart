import 'package:libledger/libledger.dart';
import 'package:test/test.dart';

void castAndCheck<T>(dynamic x, void Function(T) f) {
  expect(x, isA<T>());
  f(x as T);
}

void main() {
  group('Parser', () {
      setUp(() {});

      test('Parses empty string as no statements', () {
          castAndCheck<ParseSuccess>(parseStatements(''), (result) {
              expect(result.statements, isEmpty);
          });
      });

      test('Incremental test for parsing', () {
          castAndCheck<ParseSuccess>(parseStatements('2010/10/01'), (result) {
              expect(result.statements.length, equals(1));
              expect(result.statements.first.date.date1, equals('2010/10/01'));
          });
      });
  });
}
