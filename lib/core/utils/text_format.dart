String stripArticleMarkers(String text) {
  var result = text;
  result = result.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*'),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAllMapped(
    RegExp(r'__(.+?)__'),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAll(RegExp(r'^#\s+', multiLine: true), '');
  result = result.replaceAll(RegExp(r'^-\s+', multiLine: true), '• ');
  return result;
}
