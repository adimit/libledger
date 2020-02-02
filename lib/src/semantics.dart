import 'package:petitparser/petitparser.dart';
import 'grammar.dart';
import 'data.dart';

class LedgerParser extends GrammarParser {
  LedgerParser() : super(const LedgerParserDefinition());
}

class LedgerParserDefinition extends LedgerGrammarDefinition {
  const LedgerParserDefinition();

  @override
  Parser start() =>
      super.start().map((parses) => parses.whereType<Statement>());

  @override
  Parser<DateTime> singleDate() =>
      super.singleDate().map((parse) => DateTime(parse[0], parse[1], parse[2]));

  @override
  Parser<Date> date() => super.date().map((parse) => Date(parse[0], parse[1]));

  @override
  Parser<TransactionLine> transfer() => super.transfer().map((result) =>
      TransactionLine(Account(result[0].cast<String>()), result[1]));

  @override
  Parser<Amount> amount() =>
      super.amount().map((result) => Amount(result[0], result[1]));

  @override
  Parser<Transaction> transaction() => super.transaction().map((parseResult) {
        return Transaction(parseResult[1], parseResult[0],
            parseResult[2].cast<TransactionLine>());
      });

  @override
  Parser<AccountDeclaration> accountDeclaration() => super
      .accountDeclaration()
      .map((result) => AccountDeclaration(Account(result.cast<String>())));
}
