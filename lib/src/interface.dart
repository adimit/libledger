import 'data.dart';
import 'semantics.dart';
import 'package:petitparser/petitparser.dart';

ParseResult parseTransactions(String text) {
  final parseResult = LedgerParser().parse(text);
  if (parseResult is Success) {
    return ParseSuccess(List<Statement>.from(parseResult.value));
  } else {
    return ParseError(parseResult.toPositionString(), parseResult.message);
  }
}

String renderTransactions(List<Statement> statements) {
  return 'TODO';
}
