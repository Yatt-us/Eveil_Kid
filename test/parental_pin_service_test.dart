import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/core/services/parental_pin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ParentalPinService Unit Tests', () {
    late ParentalPinService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = ParentalPinService();
    });

    test('Initial state: hasPin() returns false when no PIN is set', () async {
      final hasPin = await service.hasPin();
      expect(hasPin, isFalse);

      final storedPin = await service.getPin();
      expect(storedPin, isNull);
    });

    test('setPin() saves 4-digit PIN and hasPin() returns true', () async {
      final saved = await service.setPin('1234');
      expect(saved, isTrue);

      final hasPin = await service.hasPin();
      expect(hasPin, isTrue);

      final stored = await service.getPin();
      expect(stored, equals('1234'));
    });

    test('setPin() throws ArgumentError if length != 4', () async {
      expect(() => service.setPin('12'), throwsArgumentError);
      expect(() => service.setPin('12345'), throwsArgumentError);
      expect(() => service.setPin(''), throwsArgumentError);
    });

    test('verifyPin() validates correct and rejects incorrect PIN', () async {
      await service.setPin('4321');

      final isCorrect = await service.verifyPin('4321');
      expect(isCorrect, isTrue);

      final isIncorrect = await service.verifyPin('1234');
      expect(isIncorrect, isFalse);

      final isWrongLength = await service.verifyPin('432');
      expect(isWrongLength, isFalse);
    });

    test('changePin() updates PIN when old PIN is correct', () async {
      await service.setPin('1111');

      final changed = await service.changePin(
        oldPin: '1111',
        newPin: '2222',
      );
      expect(changed, isTrue);

      final verifiedNew = await service.verifyPin('2222');
      expect(verifiedNew, isTrue);

      final verifiedOld = await service.verifyPin('1111');
      expect(verifiedOld, isFalse);
    });

    test('changePin() fails when old PIN is incorrect', () async {
      await service.setPin('1111');

      final changed = await service.changePin(
        oldPin: '9999',
        newPin: '2222',
      );
      expect(changed, isFalse);

      final current = await service.getPin();
      expect(current, equals('1111'));
    });

    test('clearPin() removes stored PIN completely', () async {
      await service.setPin('9876');
      expect(await service.hasPin(), isTrue);

      await service.clearPin();
      expect(await service.hasPin(), isFalse);
      expect(await service.getPin(), isNull);
    });
  });
}
