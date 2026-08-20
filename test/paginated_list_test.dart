import 'package:flutter_test/flutter_test.dart';
import 'package:movil_unistock/shared/utils/paginated_list.dart';

void main() {
  group('paginated list helpers', () {
    test('returns the first page of items', () {
      final items = List<int>.generate(7, (index) => index + 1);

      final visibleItems = paginateItems(items, visibleCount: 5, pageSize: 5);

      expect(visibleItems, [1, 2, 3, 4, 5]);
    });

    test('reports that there are more items available', () {
      final items = List<int>.generate(7, (index) => index + 1);

      final hasMore = hasMoreItems(items, visibleCount: 5, pageSize: 5);

      expect(hasMore, isTrue);
    });

    test('advances the visible count without exceeding the total', () {
      final items = List<int>.generate(7, (index) => index + 1);

      final nextCount = nextVisibleCount(items, visibleCount: 5, pageSize: 5);

      expect(nextCount, 7);
    });
  });
}
