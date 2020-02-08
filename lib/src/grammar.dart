import 'package:petitparser/petitparser.dart';

class LedgerGrammar extends GrammarParser {
  LedgerGrammar() : super(const LedgerGrammarDefinition());
}

class LedgerGrammarDefinition extends GrammarDefinition {
  const LedgerGrammarDefinition();

  @override
  Parser start() =>
      (emptyLine() | ref(transaction) | ref(accountDeclaration)).star().end();

  Parser inlineSpace() => char(' ', 'single space') | char('\t', 'single tab');

  Parser newline() => char('\n');

  Parser emptyLine() =>
      (ref(inlineSpace).plus() & ref(newline)) |
      ref(inlineSpace).plus().end() |
      ref(newline);

  Parser transaction() =>
      ref(date) &
      (ref(inlineSpace).plus() & ref(description)).pick(1).optional() &
      (ref(inlineSpace).star() &
              ref(newline) &
              ref(transfer).separatedBy(char('\n'), includeSeparators: false))
          .pick(2);

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

  Parser amountValue() =>
      char('-', 'negative sign').optional() &
      ((ref(radixCommaOnly) | ref(radixPeriodOnly)) |
          (ref(radixCommaWith1k) | ref(radixPeriodWith1k)));

  Parser radixCommaOnly() =>
      digit('digits before radix comma')
          .plus()
          .flatten('integer part expected') &
      ref(radixComma).optional() &
      char('.').not('not followed by period');

  Parser radixPeriodOnly() =>
      digit('digits before radix period')
          .plus()
          .flatten('integer part expected') &
      ref(radixPeriod).optional() &
      char(',').not('not followed by comma');

  Parser radixComma() =>
      (char(',', 'radix comma') & digit('decimal digit').plus().flatten())
          .pick(1);

  Parser radixPeriod() =>
      (char('.', 'radix period') & digit('decimal digit').plus().flatten())
          .pick(1);

  Parser radixCommaWith1k() =>
      digit('digits before radix comma with 1k')
          .plus()
          .flatten('integer part')
          .separatedBy(
              char(' ', '1k sep space') |
                  char('.', '1k sep period') |
                  char(' ', '1k sep thin space'),
              includeSeparators: false)
          .map((thousandGroups) => thousandGroups.join()) &
          ref(radixComma).optional() &
      char('.').not('not followed by period');

  Parser radixPeriodWith1k() =>
      digit('digits before radix period with 1k')
          .plus()
          .flatten('integer part')
          .separatedBy(char(',', '1k sep comma'), includeSeparators: false)
          .map((groups) => groups.join()) &
      ref(radixPeriod).optional() &
      char(',').not('not followed by comma');

  Parser amountCurrency() =>
      ((digit() | char('-') | whitespace()).not() & any()).plus().flatten();

  Parser account() =>
      ref(accountSegment).separatedBy(char(':'), includeSeparators: false);

  Parser accountSegment() =>
      ((string('  ') | char('\n') | char(':')).not('account segment') & any())
          .plus()
          .flatten();

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

  Parser accountDeclaration() => (string('account', 'account declaration') &
          ref(inlineSpace).plus() &
          ref(account) &
          ref(inlineSpace).star())
      .pick(2);
}
