import 'package:flutter_test/flutter_test.dart';
import 'package:scenagram_web/features/perspectives/perspective_item.dart';

void main() {
  test('PerspectiveItem extraction preserves behavior', () {
    final item = PerspectiveItem('Test perspective');

    expect(item.text, 'Test perspective');
    expect(item.upvotes, 0);

    item.upvotes += 1;

    expect(item.upvotes, 1);
  });
}
