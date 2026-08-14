List<T> paginateItems<T>(
  List<T> items, {
  required int visibleCount,
  required int pageSize,
}) {
  final safeVisibleCount = visibleCount.clamp(0, items.length);
  return items.take(safeVisibleCount).toList();
}

bool hasMoreItems<T>(
  List<T> items, {
  required int visibleCount,
  required int pageSize,
}) {
  return visibleCount < items.length;
}

int nextVisibleCount<T>(
  List<T> items, {
  required int visibleCount,
  required int pageSize,
}) {
  return (visibleCount + pageSize).clamp(0, items.length);
}
