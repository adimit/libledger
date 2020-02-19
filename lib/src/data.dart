import 'package:decimal/decimal.dart';

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
  final List<Statement> transactions;
  ParseSuccess(this.transactions);
}

class Account {
  final List<String> path;

  Account(this.path);

  @override
  String toString() => 'Account: ${path.toString()}';
}

class Amount {
  final Decimal _value;
  final String currency; // nullable

  Amount._(this._value, this.currency);

  /// Create an amount from [value] in [currency]. [value] MUST be formatted
  /// without 1k separators and with a period radix. It MAY carry a sign and/or a scientific
  /// notation exponent. OK: -2134.24e2. Not OK: 1.345,30
  /// [currency] is an arbitrary string discriminator. It does not have any semantics.
  factory Amount(String value, String currency) =>
      Amount._(Decimal.parse(value), currency);

  @override
  String toString() =>
      _value.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '') +
      ((currency == null) ? '' : ' $currency');

  @override
  int get hashCode => _value.hashCode ^ currency.hashCode;

  @override
  // FIXME for some reason, the runtime types are always different, and the
  // 'is' typecheck fails. Even though they *are* the same runtime type
  bool operator ==(o) =>
      o.runtimeType.toString() == runtimeType.toString() &&
      o.hashCode == hashCode;
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

class AccountDeclaration implements Statement {
  final Account account;

  AccountDeclaration(this.account);

  @override
  String toString() => 'Account declaration: ${account}';
}

class CommodityDeclaration implements Statement {
  final String radix;
  final String currency;
  final String thousandSeparator; // nullable

  CommodityDeclaration(this.radix, this.currency, this.thousandSeparator);

  @override
  String toString() => 'commodity 1${thousandSeparator}000$radix $currency';
}
