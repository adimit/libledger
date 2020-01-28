import 'package:petitparser/petitparser.dart';

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

  Parser amount() {
    final value = () => (ref(amountValue) & ref(inlineSpace).star()).pick(0);
    final currency =
        () => (ref(amountCurrency) & ref(inlineSpace).star()).pick(0);
    return (ref(value) & ref(currency)) |
        (ref(currency) & ref(value)).map((result) => result.reversed.toList()) |
        ref(value);
  }

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
