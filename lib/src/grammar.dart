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

  Parser amount() => ((ref(value) & ref(currency)) |
          (ref(currency) & ref(value))
              .map((result) => result.reversed.toList()) |
          ref(value).map((result) => [result, null]))
      .settable();

  Parser value() => (ref(amountValue) & ref(inlineSpace).star()).pick(0);
  Parser currency() => (ref(amountCurrency) & ref(inlineSpace).star()).pick(0);

  Parser amountValue() =>
      char('-', 'negative sign').optional() &
      ((ref(radixCommaWith1k) | ref(radixPeriodWith1k)) |
          (ref(radixCommaOnly) | ref(radixPeriodOnly)));

  Parser radixCommaOnly() => (digit('digits before radix comma')
              .plus()
              .flatten('integer part expected') &
          ref(radixComma).optional() &
          (char('.') | (char(' ') & digit())).not('not followed by period'))
      .map((results) => [
            results,
            [null, ',']
          ]);

  Parser radixPeriodOnly() => (digit('digits before radix period')
              .plus()
              .flatten('integer part expected') &
          ref(radixPeriod).optional() &
          char(',').not('not followed by comma'))
      .map((results) => [
            results,
            [null, '.']
          ]);

  Parser radixComma() =>
      (char(',', 'radix comma') & digit('decimal digit').plus().flatten())
          .pick(1);

  Parser radixPeriod() =>
      (char('.', 'radix period') & digit('decimal digit').plus().flatten())
          .pick(1);

  Parser radixCommaWith1k() =>
      ref(radixCommaWith1kAndDynamicSeparator, '.') |
      ref(radixCommaWith1kAndDynamicSeparator, ' ') |
      ref(radixCommaWith1kAndDynamicSeparator, ' ');

  Parser radixCommaWith1kAndDynamicSeparator(String separator) =>
      (digit('digits before radix comma with 1k')
                  .plus()
                  .flatten('integer part')
                  .separatedBy(char(separator, '1k sep space'), includeSeparators: false)
                  .map((thousandGroups) => thousandGroups.join()) &
              ref(radixComma) &
              char('.').not('not followed by period'))
          .map((results) => [results, [separator, ',']]);

  Parser commodity() =>
      (string('commodity') & ref(inlineSpace).plus() & ref(amount)).pick(2);

  Parser radixPeriodWith1k() => (digit('digits before radix period with 1k')
              .plus()
              .flatten('integer part')
              .separatedBy(char(',', '1k sep comma'), includeSeparators: false)
              .map((groups) => groups.join()) &
          ref(radixPeriod) &
          char(',').not('not followed by comma'))
      .map((results) => [
            results,
            [',', '.']
          ]);

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
