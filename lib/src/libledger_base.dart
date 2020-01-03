abstract class ParseResult {}

class ParseError implements ParseResult {
  final int lineNumber;
  final int columnNumber;
  final String message;

  ParseError(this.lineNumber, this.columnNumber, this.message);
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

class Statement {
  final String description;
  final String comment;
  final String date;
  final List<StatementLine> lines;

  Statement(this.description, this.comment, this.date, this.lines);
}

List<Statement> parseStatements(String text) {
  return [Statement('description', 'comment', 'date', [])];
}

String renderStatements(List<Statement> statements) {
  return '';
}
