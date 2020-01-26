import 'package:libledger/libledger.dart';
import 'package:test/test.dart';

void castAndCheck<T>(dynamic x, void Function(T) f) {
  expect(x, isA<T>(), reason: 'Expected ${T} but got ${x.toString()}');
  f(x as T);
}

// When we don't need an assertion, because we just want a successful parse
void noop(dynamic anyArgument) {
  expect(true, isTrue);
}

void parseSuccess(String description, String subject,
    [void Function(List<Transaction>) assertions = noop]) {
  test('parses $description', () {
    castAndCheck<ParseSuccess>(parseTransactions(subject), (result) {
      assertions(result.transactions);
    });
  });
}

void parseFailure(String description, String subject,
    [void Function(ParseError error) assertions = noop]) {
  test('does not parse $description', () {
    castAndCheck<ParseError>(parseTransactions(subject), (result) {
      assertions(result);
    });
  });
}

void main() {
  group('Parser', () {
    setUp(() {});

    parseSuccess('empty string as no transactions', '', (transactions) {
      expect(transactions, isEmpty);
    });

    parseSuccess('blank string as no transactions', '  \t\n\n ',
        (transactions) {
      expect(transactions, isEmpty);
    });

    parseSuccess('transaction declaration with one line',
        '''2020/01/09 this is a description
        Account:Number One:Foo''', (transactions) {
      expect(transactions.length, equals(1));
      expect(transactions.first.date.date1, equals(DateTime(2020, 1, 9)));
      expect(transactions.first.date.date2, isNull);
      expect(transactions.first.description, equals('this is a description'));
      expect(transactions.first.lines.first.account.path,
          equals(['Account', 'Number One', 'Foo']));
    });

    parseSuccess(
        'second date parsed correctly', '''2020/01/22=2020/01/23 description
      Account:foo''', (transactions) {
      expect(transactions.first.date.date1, equals(DateTime(2020, 01, 22)));
      expect(transactions.first.date.date2, equals(DateTime(2020, 01, 23)));
    });

    parseSuccess('transfer with account and amount more whitespace',
        '''2020/01/09 description
        Account:Number1            20    EUR''', (transactions) {
      expect(transactions.first.lines.first.amount.value, equals('20'));
      expect(transactions.first.lines.first.account.path,
          equals(['Account', 'Number1']));
    });

    parseSuccess('transfer with two accounts', '''2020/01/09 description
            Account:Number1  20 EUR
            Account:Number2  -20 EUR''', (transactions) {
      expect(transactions.first.lines[1].account.path,
          equals(['Account', 'Number2']));
    });
    parseSuccess('transfer with two accounts, and only one amount',
        '''2020/01/09 description
            Account:Number1  20 EUR
            Account:Number2''', (transactions) {
      expect(transactions.first.lines[1].amount, isNull);
    });
    parseSuccess('extraneous whitespaces around transaction', '''

2020/01/09     description     
            Account:Number1           20 EUR        
            Account:Number3      -20 EUR
            Account:Number2         


            ''');

    parseFailure('a transaction whose lines starts with spaces',
        '   2020-01-17 description\n  foo');

    parseSuccess('amount with currency in front of value',
        '2020-01-25 description\n  foo  EUR 25.00', (transactions) {
      expect(transactions.first.lines.first.amount.currency, equals('EUR'));
      expect(transactions.first.lines.first.amount.value, equals('25.00'));
    });
    parseSuccess('amount with comma as decimal separator',
        '2020-01-25 description\n  foo  EUR 25,00', (transactions) {
      expect(transactions.first.lines.first.amount.value, equals('25,00'));
    });
    parseSuccess('amount with negative value',
        '2020-01-25 description\n  foo  EUR -25,00', (transactions) {
      expect(transactions.first.lines.first.amount.value, equals('-25,00'));
    });

    parseSuccess('amount parses correctly without spaces',
        '2020-01-25 description\n  foo  -25.00€\n  \n  foo ₤35', (transactions) {
      expect(transactions.first.lines.first.amount.value, equals('-25.00'));
      expect(transactions.first.lines.first.amount.currency, equals('€'));
      expect(transactions.first.lines[1].amount.value, equals('35'));
      expect(transactions.first.lines[1].amount.currency, equals('₤'));
    });
    group("Tests that don't run yet", () {},
        skip: 'TODO need to fix implementation');
  });
}
