import 'package:libledger/libledger.dart';
import 'package:test/test.dart';

void castAndCheck<T>(dynamic x, [void Function(T) f = noop]) {
  expect(x, isA<T>(), reason: 'Expected ${T} but got ${x.toString()}');
  f(x as T);
}

// When we don't need an assertion, because we just want a successful parse
void noop(dynamic anyArgument) {
  expect(true, isTrue);
}

void parseSuccess<T extends Statement>(String description, String subject,
    [void Function(List<T>) assertions = noop]) {
  test('parses $description', () {
    castAndCheck<ParseSuccess>(parseTransactions(subject), (result) {
      assertions(result.transactions.cast<T>());
    });
  });
}

void parseFailure(String description, String subject,
    [void Function(ParseError error) assertions = noop]) {
  test('Does not parse $description', () {
    castAndCheck<ParseError>(parseTransactions(subject), (result) {
      assertions(result);
    });
  });
}
