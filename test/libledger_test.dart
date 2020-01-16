import 'package:libledger/libledger.dart';
import 'package:test/test.dart';

void castAndCheck<T>(dynamic x, void Function(T) f) {
  expect(x, isA<T>(), reason: 'Expected ${T} but got ${x.toString()}');
  f(x as T);
}

// When we don't need an assertion, because we just want a successful parse
void noop(List<Transaction> transactions) {
  expect(true, isTrue);
}

void parseTest(String description, String subject,
    [void Function(List<Transaction>) assertions = noop]) {
  test('Parses $description', () {
    castAndCheck<ParseSuccess>(parseTransactions(subject), (result) {
      assertions(result.transactions);
    });
  });
}

void main() {
  group('Parser', () {
    setUp(() {});

    parseTest('empty string as no transactions', '', (transactions) {
      expect(transactions, isEmpty);
    });

    parseTest('blank string as no transactions', '    \t\n\n  ',
        (transactions) {
      expect(transactions, isEmpty);
    });

    parseTest('transaction declaration with one line',
        '''2020/01/09 this is a description
        Account:Number One:Foo''', (transactions) {
      expect(transactions.length, equals(1));
      expect(transactions.first.date.date1, equals('2020/01/09'));
      expect(transactions.first.description, equals('this is a description'));
      expect(transactions.first.lines.first.account,
          equals('Account:Number One:Foo'));
    });
    parseTest('transfer with account and amount more whitespace',
        '''2020/01/09 description
        Account:Number1            20 EUR''', (transactions) {
      expect(transactions.first.lines.first.amount, equals('20 EUR'));
      expect(transactions.first.lines.first.account, equals('Account:Number1'));
    });

    parseTest('transfer with two accounts', '''2020/01/09 description
            Account:Number1  20 EUR
            Account:Number2  -20 EUR
            ''', (transactions) {
      expect(transactions.first.lines[1].amount, equals('-20 EUR'));
    });
    parseTest('transfer with two accounts, and only one amount',
        '''2020/01/09 description
            Account:Number1  20 EUR
            Account:Number2
            ''', (transactions) {
              expect(transactions.first.lines[1].amount, isNull);
          });
    parseTest('extraneous whitespaces around transaction', '''

            2020/01/09     description     
            Account:Number1           20 EUR        
            Account:Number3      -20 EUR
            Account:Number2         


            ''');
    group("Tests that don't run yet", () {},
        skip: 'TODO need to fix implementation');
  });
}
