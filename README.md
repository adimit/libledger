# Description

Experimental parsing support for the [ledger](https://www.ledger-cli.org/) file
format.

# License

See the `LICENSE` file.

## Usage

A simple usage example:

```dart
import 'package:libledger/libledger.dart';

main() {
  final someString = // get from file
  final parseResult = parseTransactions(someString)
  if (parseResult is ParseSuccess) {
    // handle success case. Transactions are in parseResult.transactions
  } else {
    // handle error case. You can use parseResult.positionDescription, and parseResult.message.
  }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/adimit/libledger/issues
