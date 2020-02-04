import 'package:libledger/libledger.dart';
import 'package:test/test.dart';

void main() {
  group('Data', () {
    test('Amount with currency parses and serialises correctly', () {
      expect(Amount('1.23', 'EUR').toString(), equals('1.23 EUR'));
    });
    test('Amount without currency does not serialise currency', () {
      expect(Amount('1.23', null).toString(), equals('1.23'));
    });
    test('Amount with arbitrary precision serialises with 2 decimal places',
        () {
      expect(Amount('1.239', null).toString(), startsWith('1.24'));
    });
    test('Integer amount does not render decimal places', () {
        expect(Amount('1', null).toString(), startsWith('1'));
    });
  });
}
