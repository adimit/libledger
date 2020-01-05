import 'package:petitparser/petitparser.dart';

abstract class ParseResult {}

class ParseError implements ParseResult {
  final String positionDescription;
  final String message;

  ParseError(this.positionDescription, this.message);
}

class ParseSuccess implements ParseResult {
  final List<Statement> statements;
  ParseSuccess(this.statements);
}

class StatementLine {
  final String account;
  final String amount;

  StatementLine(this.account, this.amount);
}

class Date {
  final String date1;
  // final String date2;

  Date(this.date1 /*, this.date2*/);
}

class Statement {
  // final String description;
  // final String comment;
  final Date date;
  // final List<StatementLine> lines;

  Statement(/*this.description, this.comment, */ this.date /*, this.lines*/);
}

ParseResult parseStatements(String text) {
  final parseResult = LedgerParser().parse(text);
  if (parseResult is Success) {
    return ParseSuccess(List<Statement>.from(parseResult.value));
  } else {
    return ParseError(parseResult.toPositionString(), parseResult.message);
  }
}

String renderStatements(List<Statement> statements) {
  return '';
}

// Grammar

class LedgerGrammar extends GrammarParser {
  LedgerGrammar() : super(const LedgerGrammarDefinition());
}

class LedgerGrammarDefinition extends GrammarDefinition {
  const LedgerGrammarDefinition();

  @override
  Parser start() => ref(statement).star().end();

  Parser statement() => ref(date);
  Parser<String> date() => (digit() | char('/') | char('-') | char(' ') | char('.')).plus().flatten();
}

// Parser

class LedgerParser extends GrammarParser {
  LedgerParser() : super(const LedgerParserDefinition());
}

class LedgerParserDefinition extends LedgerGrammarDefinition {
  const LedgerParserDefinition();

  @override
  Parser<Statement> statement() => super.date().map((value) => Statement(Date(value)));
}
