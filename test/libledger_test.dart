import 'package:libledger/libledger.dart';
import 'package:petitparser/petitparser.dart';
import '../lib/src/grammar.dart';
import '../lib/src/semantics.dart';
import 'package:test/test.dart';

void castAndCheck<T>(dynamic x, void Function(T) f) {
  expect(x, isA<T>(), reason: 'Expected ${T} but got ${x.toString()}');
  f(x as T);
}

// When we don't need an assertion, because we just want a successful parse
void noop(dynamic anyArgument) {
  expect(true, isTrue);
}

void parseSuccess<T extends Statement>(String description, String subject,
    [void Function(List<T>) assertions = noop]) {
  test('parses $description', () {
    castAndCheck<ParseSuccess>(parseTransactions(subject), (result) {
      assertions(result.transactions.cast<T>());
    });
  });
}

void parseFailure(String description, String subject,
    [void Function(ParseError error) assertions = noop]) {
  test('Does not parse $description', () {
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

    parseSuccess<Transaction>('transaction declaration with one line',
        '''2020/01/09 this is a description
        Account:Number One:Foo''', (transactions) {
      expect(transactions.length, equals(1));
      expect(transactions.first.date.date1, equals(DateTime(2020, 1, 9)));
      expect(transactions.first.date.date2, isNull);
      expect(transactions.first.description, equals('this is a description'));
      expect(transactions.first.lines.first.account.path,
          equals(['Account', 'Number One', 'Foo']));
    });

    parseSuccess<Transaction>(
        'second date parsed correctly', '''2020/01/22=2020/01/23 description
      Account:foo''', (transactions) {
      expect(transactions.first.date.date1, equals(DateTime(2020, 01, 22)));
      expect(transactions.first.date.date2, equals(DateTime(2020, 01, 23)));
    });

    parseSuccess<Transaction>(
        'transfer with account and amount more whitespace',
        '''2020/01/09 description
        Account:Number1            20    EUR''', (transactions) {
      expect(
          transactions.first.lines.first.amount.toString(), equals('20 EUR'));
      expect(transactions.first.lines.first.account.path,
          equals(['Account', 'Number1']));
    });

    parseSuccess<Transaction>(
        'transfer with two accounts', '''2020/01/09 description
            Account:Number1  20 EUR
            Account:Number2  -20 EUR''', (transactions) {
      expect(transactions.first.lines[1].account.path,
          equals(['Account', 'Number2']));
    });
    parseSuccess<Transaction>('transfer with two accounts, and only one amount',
        '''2020/01/09 description
            Account:Number1  20 EUR
            Account:Number2''', (transactions) {
      expect(transactions.first.lines[1].amount, isNull);
    });
    parseSuccess<Transaction>('extraneous whitespaces around transaction', '''

2020/01/09     description     
            Account:Number1           20 EUR        
            Account:Number3      -20 EUR
            Account:Number2         


            ''');

    parseFailure('a transaction whose lines starts with spaces',
        '   2020-01-17 description\n  foo');

    parseSuccess<Transaction>('amount with currency in front of value',
        '2020-01-25 description\n  foo  EUR 25.00', (transactions) {
      expect(
          transactions.first.lines.first.amount.toString(), equals('25 EUR'));
    });
    parseSuccess<Transaction>('amount with comma as decimal separator',
        '2020-01-25 description\n  foo  EUR 25,00', (transactions) {
      expect(
          transactions.first.lines.first.amount.toString(), equals('25 EUR'));
    });
    parseSuccess<Transaction>('amount with negative value',
        '2020-01-25 description\n  foo  EUR -25,00', (transactions) {
      expect(
          transactions.first.lines.first.amount.toString(), equals('-25 EUR'));
    });
    parseSuccess<Transaction>(
        'transaction without description', '2020/01/29\n  Account:Foo  20 EUR',
        (transactions) {
      expect(transactions.first.description, isNull);
    });
    parseSuccess<Transaction>(
        'transaction with blank description has null description',
        '2020/01/29     \n  Account:Foo  20 EUR', (transactions) {
      expect(transactions.first.description, isNull);
    });

    parseSuccess<Transaction>('amount parses correctly without spaces',
        '2020-01-25 description\n  foo  -25.00€\n  \n  foo  ₤35',
        (transactions) {
      expect(transactions.first.lines.first.amount.toString(), equals('-25 €'));
      expect(transactions.first.lines[1].amount.toString(), equals('35 ₤'));
    });

    parseSuccess<AccountDeclaration>('account declaration', 'account Foo:Bar',
        (accounts) {
      expect(accounts.first.account.path, equals(['Foo', 'Bar']));
    });

    parseSuccess<AccountDeclaration>(
        'two account declarations', 'account Foo:Bar\naccount Bar:Foo',
        (accounts) {
      expect(accounts.length, equals(2));
    });

    parseFailure('account declaration without account', 'account   ');

    parseFailure(
        'account declaration starting with a space', '   account Foo:Bar');

    parseSuccess<Statement>('mixed transaction and account',
        '2020-02-01\n  Foo:Bar  30\naccount Foo:Bar', (statements) {
      expect(statements[0], isA<Transaction>());
      expect(statements[1], isA<AccountDeclaration>());
    });

    parseSuccess<Statement>('mixed account and transaction',
        'account Foo:Bar Baz\n2020-02-02\n  Foo:Foo  30', (statements) {
      expect(statements[0], isA<AccountDeclaration>());
      expect(statements[1], isA<Transaction>());
    });

    parseSuccess<AccountDeclaration>('account without subpath', 'account Foo',
        (accounts) => expect(accounts.first.account.path, equals(['Foo'])));

    group('number format', () {
      ({
        'amount with 1k-space and radix comma': '1 000,50 €',
        'amount with 1k-thin-space and radix comma': '1 000,50 €',
        'amount with 1k-period and radix comma': '1.000,50 €',
        'amount with 1k-comma and radix period': '1,000.50 €',
        'amount without 1k separator and radix comma': '1000,50 €',
        'amount without 1k separator and radix period': '1000.50 €'
      }).forEach((comment, number) {
        parseSuccess<Transaction>(comment, '2020-02-05\n  foo  $number',
            (transactions) {
          expect(transactions.first.lines.first.amount.toString(),
              equals('1000.50 €'));
        });

        // and negative numbers
        parseSuccess<Transaction>(
            'negative $comment', '2020-02-05\n  foo  -$number', (transactions) {
          expect(transactions.first.lines.first.amount.toString(),
              equals('-1000.50 €'));
        });
      });
    });

    void expectDefinition<T extends Result>(LedgerGrammarDefinition def,
        Function start, String specimen, dynamic expected) {
      final functionName = start.toString().substring(42);
      test('$functionName should parse $specimen as $T', () {
        final result = def.build(start: start).parse(specimen);
        expect(result, isA<T>());
        if (expected != null) {
          expect(result.value, equals(expected));
        }
      });
    }

    group('parser definitions', () {
      final def = LedgerParserDefinition();
      final expectParser = <T extends Result>(start, specimen, [assertions]) =>
          expectDefinition<T>(def, start, specimen, assertions);

      expectParser<Success>(def.amount, '1', Amount('1.0', null));
      expectParser<Success>(def.amount, '1.0', Amount('1.0', null));
      expectParser<Success>(def.amount, '1.0 €', Amount('1.0', '€'));
    });

    group('grammar definitions', () {
      final def = LedgerGrammarDefinition();
      final expectGrammar = <T extends Result>(start, specimen, [assertions]) =>
          expectDefinition<T>(def, start, specimen, assertions);

      group('commodity', () {
        expectGrammar<Success>(def.commodity, 'commodity 1,000.00 EUR');
        expectGrammar<Success>(def.commodity, 'commodity 1 000.00 EUR');
        expectGrammar<Success>(def.commodity, 'commodity 1 000.00 EUR');
        expectGrammar<Success>(def.commodity, 'commodity 1.000,00 EUR');
        expectGrammar<Success>(def.commodity, 'commodity EUR 1.000,00');
        expectGrammar<Failure>(def.commodity, 'commodity');
      });

      group('amount', () {
        expectGrammar<Success>(def.amountValue, '1 0,0', [
          null,
          [
            ['10', '0', null],
            [' ', ',']
          ]
        ]);
        expectGrammar<Success>(def.amountValue, '1.0,0', [
          null,
          [
            ['10', '0', null],
            ['.', ',']
          ]
        ]);
        expectGrammar<Success>(def.amountValue, '1,0.0', [
          null,
          [
            ['10', '0', null],
            [',', '.']
          ]
        ]);
        expectGrammar<Success>(def.amountValue, '1');

        expectGrammar<Success>(def.radixPeriodOnly, '1');
        expectGrammar<Success>(def.radixCommaOnly, '1');
        expectGrammar<Failure>(def.radixPeriodWith1k, '1');
        expectGrammar<Failure>(def.radixCommaWith1k, '1');

        expectGrammar<Success>(def.radixPeriodOnly, '1.0');
        expectGrammar<Failure>(def.radixPeriodOnly, '1,0');
        expectGrammar<Failure>(def.radixPeriodOnly, '1.0,0');

        expectGrammar<Success>(def.radixCommaOnly, '1,0');
        expectGrammar<Failure>(def.radixCommaOnly, '1.0');
        expectGrammar<Failure>(def.radixCommaOnly, '1,0.0');

        expectGrammar<Success>(def.radixCommaWith1k, '1.0,0');
        expectGrammar<Success>(def.radixCommaWith1k, '1 0,0');
        expectGrammar<Success>(def.radixCommaWith1k, '1 0,0');
        expectGrammar<Success>(def.radixCommaWith1k, '10,0');
        expectGrammar<Failure>(def.radixCommaWith1k, '1,0.0');

        expectGrammar<Success>(def.radixPeriodWith1k, '1,0.0');
        expectGrammar<Failure>(def.radixPeriodWith1k, '1.0,0');
      });
    });
  });
}
