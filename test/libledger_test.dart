import 'package:libledger/libledger.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    setUp(() {});

    test('Parses empty string as no statements', () {
      final result = parseStatements('');
      expect(result, equals([]));
    });

    test('Parses simple statement correctly', () {
      final result = parseStatements('''
            2020-01-01 Some Description ; Comment
              Assets:Test Account  23 EUR
              Expenses:Test Run
            ''');
          expect(result, equals([
                Statement(
                  'Some Description',
                  'Comment',
                  '2020-01-01',
                  [ StatementLine('Assets:Test Account', '23 EUR')
                  , StatementLine('Expenses:Test Run', '')]
                )
          ]));
    });
  });
}
