import 'package:test/test.dart';

int calculate() {
  return 42;
}

void main() {
  test('calculate', () {
    expect(calculate(), 42);
  });
}
