import 'package:libledger/libledger.dart';
import 'package:test/test.dart';

void castAndCheck<T>(dynamic x, void Function(T) f) {
  expect(x, isA<T>(), reason: 'Cannot cast ${x.toString()} to ${T}');
  f(x as T);
}

void main() {
  group('Parser', () {
    setUp(() {});

    test('Parses empty string as no transactions', () {
      castAndCheck<ParseSuccess>(parseTransactions(''), (result) {
        expect(result.transactions, isEmpty);
      });
    });

    test('Incremental test for parsing', () {
      castAndCheck<ParseSuccess>(parseTransactions('''2010/10/01 description foo bar ä
          foobar
'''),
          (result) {
        expect(result.transactions.length, equals(1));
        expect(result.transactions.first.date.date1, equals('2010/10/01'));
        expect(result.transactions.first.description, equals('description foo bar ä'));
      });
    });
  });
}
