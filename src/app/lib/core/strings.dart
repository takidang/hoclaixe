/// All user-facing text in one place (NFR-09).
abstract final class S {
  static const appName = 'Học lái xe';
  static const loading = 'Đang nạp dữ liệu…';
  static const contentError =
      'Không đọc được dữ liệu câu hỏi. Hãy cài lại ứng dụng.';
  static String contentLoaded(int questions, int signs) =>
      'Đã nạp $questions câu hỏi · $signs biển báo';
  static String contentVersion(String v) => 'Phiên bản dữ liệu: $v';
}
