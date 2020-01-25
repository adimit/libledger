import 'package:petitparser/petitparser.dart';

abstract class ParseResult {}

class ParseError implements ParseResult {
  final String positionDescription;
  final String message;

  ParseError(this.positionDescription, this.message);

  @override
  String toString() =>
      'Parse error: ${message}, position: ${positionDescription}';
}

class ParseSuccess implements ParseResult {
  final List<Transaction> transactions;
  ParseSuccess(this.transactions);
}

class Account {
  final List<String> path;

  Account(this.path);

  @override
  String toString() => 'Account: ${path.toString()}';
}

class Amount {
  final String value;
  final String currency; // nullable

  Amount(this.value, this.currency);
  @override
  String toString() => 'Amount: $value $currency';
}

class TransactionLine {
  final Account account;
  final Amount amount; //nullable

  TransactionLine(this.account, this.amount);

  @override
  String toString() {
    return '  $account  $amount';
  }
}

class Date {
  final DateTime date1;
  final DateTime date2; //nullable

  Date(this.date1, this.date2);

  @override
  String toString() => 'Date "${date1}"';
}

class Transaction {
  final String description;
  final Date date;
  final List<TransactionLine> lines;

  Transaction(this.description, this.date, this.lines);

  @override
  String toString() {
    return 'Transaction:\n${date.date1} $description\n';
  }
}

ParseResult parseTransactions(String text) {
  final parseResult = LedgerParser().parse(text);
  if (parseResult is Success) {
    return ParseSuccess(List<Transaction>.from(parseResult.value));
  } else {
    return ParseError(parseResult.toPositionString(), parseResult.message);
  }
}

String renderTransactions(List<Transaction> transactions) {
  return '';
}

// Grammar
class LedgerGrammar extends GrammarParser {
  LedgerGrammar() : super(const LedgerGrammarDefinition());
}

class LedgerGrammarDefinition extends GrammarDefinition {
  const LedgerGrammarDefinition();

  @override
  Parser start() => (emptyLine() | ref(transaction)).star().end();

  Parser inlineSpace() => char(' ') | char('\t');

  Parser newline() => char('\n');

  Parser emptyLine() =>
      (ref(inlineSpace).plus() & ref(newline)) |
      ref(inlineSpace).plus().end() |
      ref(newline);

  Parser transaction() =>
      (ref(date) & whitespace().plus()).pick(0) &
      (ref(description) & char('\n')).pick(0) &
      ref(transfer).separatedBy(char('\n'), includeSeparators: false);

  Parser description() => noneOf('\n', 'description expected').plus().flatten();

  Parser transfer() =>
      (whitespace().and() & ref(account).trim() & ref(amount).optional())
          .map((parseResult) => [parseResult[1], parseResult[2]]);

  Parser amount() =>
      (ref(amountValue) & ref(inlineSpace).star()).pick(0) &
      ref(amountCurrency);

  Parser amountValue() => (char('-').optional() &
          digit() &
          (digit() | char(',') | char('.')).star())
      .flatten();

  Parser amountCurrency() =>
      ((digit() | char('-') | whitespace()).not() & any()).plus().flatten();

  Parser account() =>
      (ref(accountSegment) & (char(':') & ref(accountSegment)).pick(1).star())
          .map((accountPath) => [accountPath[0], ...accountPath[1]]);

  Parser accountSegment() =>
      ((string('  ') | char('\n') | char(':')).not() & any()).plus().flatten();

  Parser date() =>
      ref(singleDate) & (char('=') & ref(singleDate)).pick(1).optional();

  Parser yearNumeric() =>
      digit().times(4).flatten().map((string) => int.parse(string));

  Parser monthOrDayNumeric() =>
      digit().times(2).flatten().map((string) => int.parse(string));

  Parser dateDelimiter() => char('/') | char('-') | char('.');

  Parser singleDate() => (ref(yearNumeric) &
          ref(dateDelimiter) &
          ref(monthOrDayNumeric) &
          ref(dateDelimiter) &
          ref(monthOrDayNumeric))
      .map((chunks) => [chunks[0], chunks[2], chunks[4]]);
}

// Parser

class LedgerParser extends GrammarParser {
  LedgerParser() : super(const LedgerParserDefinition());
}

class LedgerParserDefinition extends LedgerGrammarDefinition {
  const LedgerParserDefinition();
  @override
  Parser start() =>
      super.start().map((parses) => parses.whereType<Transaction>());

  @override
  Parser<DateTime> singleDate() =>
      super.singleDate().map((parse) => DateTime(parse[0], parse[1], parse[2]));

  @override
  Parser<Date> date() => super.date().map((parse) => Date(parse[0], parse[1]));

  @override
  Parser<TransactionLine> transfer() => super.transfer().map((result) => TransactionLine(Account(result[0].cast<String>()), result[1]));

  @override
  Parser<Amount> amount() => super.amount().map((result) => Amount(result[0], result[1]));

  @override
  Parser<Transaction> transaction() => super.transaction().map((parseResult) {
        return Transaction(parseResult[1], parseResult[0],
            parseResult[2].cast<TransactionLine>());
      });
}
