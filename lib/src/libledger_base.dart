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

class TransactionLine {
  final String account;
  final String amount;

  TransactionLine(this.account, this.amount);

  @override
  String toString() {
    return '  $account  $amount';
  }
}

class Date {
  final String date1;
  // final String date2;

  Date(this.date1 /*, this.date2*/);

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
  Parser start() => ref(transaction).star().trim().end();

  Parser transaction() =>
      ref(date).trim() &
      ref(description) &
      char('\n') &
      (ref(transfer) & (char('\n') & ref(transfer)).pick(1).star())
          .map((value) => [value[0], ...value[1]]);
  Parser description() => noneOf('\n', 'description expected').plus().flatten();
  Parser transfer() =>
      (whitespace().and() & ref(account).trim() & ref(amount).optional())
          .map((value) {
        return [value[1], value[2]];
      });
  Parser amount() => noneOf('\n').plus().flatten();
  Parser account() =>
      ((string('  ') | char('\n')).not() & any()).plus().flatten().trim();
  Parser date() => (digit('date expected') &
          (digit('date expected') | char('/') | char('-') | char('.')).plus())
      .flatten();
}

// Parser

class LedgerParser extends GrammarParser {
  LedgerParser() : super(const LedgerParserDefinition());
}

class LedgerParserDefinition extends LedgerGrammarDefinition {
  const LedgerParserDefinition();

  @override
  Parser<Transaction> transaction() => super.transaction().map((value) {
        return Transaction(value[1], Date(value[0]), value[3]
            .map((transactionLine) =>
                TransactionLine(transactionLine[0], transactionLine[1]))
            .toList()
            .cast<TransactionLine>());
      });
}
