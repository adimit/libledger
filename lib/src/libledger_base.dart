import 'package:petitparser/petitparser.dart';

abstract class ParseResult {}

class ParseError implements ParseResult {
  final String positionDescription;
  final String message;

  ParseError(this.positionDescription, this.message);
}

class ParseSuccess implements ParseResult {
  final List<Transaction> transactions;
  ParseSuccess(this.transactions);
}

class TransactionLine {
  final String account;
  final String amount;

  TransactionLine(this.account, this.amount);
}

class Date {
  final String date1;
  // final String date2;

  Date(this.date1 /*, this.date2*/);
}

class Transaction {
  final String description;
  final Date date;
  // final List<TransactionLine> lines;

  Transaction(this.description, this.date /*, this.lines*/);
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
  Parser start() => ref(transaction).star().end();

  Parser transaction() => ref(date) & char(' ') & ref(description);
  Parser<String> description() => any('description expected').plus().flatten();
  Parser<String> date() => (digit('date expected') &
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
  Parser<Transaction> transaction() => super.transaction().map((value) => Transaction(value[2], Date(value[0])));
}
