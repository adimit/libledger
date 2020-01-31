abstract class ParseResult {}

class Statement {}

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
  String toString() => '  $account  $amount';
}

class Date {
  final DateTime date1;
  final DateTime date2; //nullable

  Date(this.date1, this.date2);

  @override
  String toString() => 'Date "${date1}"';
}

class Transaction implements Statement {
  final String description; //nullable
  final Date date;
  final List<TransactionLine> lines;

  Transaction(this.description, this.date, this.lines);

  @override
  String toString() => 'Transaction:\n${date.date1} $description\n';
}
