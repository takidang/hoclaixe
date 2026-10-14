/// All user-facing text in one place (NFR-09).
abstract final class S {
  static const appName = 'Học lái xe';
  static const appVersion = '1.0.0';
  static const loading = 'Đang nạp dữ liệu…';
  static const contentError =
      'Không đọc được dữ liệu câu hỏi. Hãy cài lại ứng dụng.';
  static const settingsError =
      'Không mở được dữ liệu tiến độ trên máy. Hãy thử mở lại ứng dụng.';
  static String contentLoaded(int questions, int signs) =>
      'Đã nạp $questions câu hỏi · $signs biển báo';
  static String contentVersion(String v) => 'Phiên bản dữ liệu: $v';

  // Disclaimer (FR-A01, FR-A02) — vision §3.2
  static const disclaimerTitle = 'Trước khi bắt đầu';
  static const disclaimerBody =
      'Học lái xe là sản phẩm độc lập (đồ án sinh viên), không đại diện cho Bộ Công an hay bất kỳ cơ quan nhà nước nào.\n\n'
      'Câu hỏi, đáp án và cấu trúc đề được lấy nguyên văn từ tài liệu chính thức. Khi có thay đổi quy định, '
      'hãy đối chiếu với nguồn chính thức của Cục Cảnh sát giao thông.';
  static const disclaimerAccept = 'Tôi đã hiểu và đồng ý';
  static const sourcesTitle = 'Nguồn dữ liệu';
  static const sources = [
    'Bộ 600 câu hỏi dùng cho sát hạch lái xe cơ giới đường bộ — Cục Cảnh sát giao thông, áp dụng từ 01/6/2025',
    'Công văn 2262/CSGT-P5 ngày 07/5/2025 — hướng dẫn sử dụng bộ câu hỏi, cấu trúc đề, câu điểm liệt',
    'Thông tư 12/2025/TT-BCA — thời gian làm bài, điểm đạt (áp dụng đến 28/02/2027)',
    'QCVN 41:2024/BGTVT — Quy chuẩn kỹ thuật quốc gia về báo hiệu đường bộ (hiệu lực 01/01/2025)',
    'Luật Trật tự, an toàn giao thông đường bộ số 36/2024/QH15 — Điều 57 (hạng giấy phép lái xe), hiệu lực 01/01/2025',
  ];
  static const officialSite = 'Đối chiếu: csgt.bocongan.gov.vn';
  static const progressLocalOnly =
      'Tiến độ học chỉ lưu trên máy này; gỡ ứng dụng sẽ mất tiến độ.';

  // Licence class (FR-A03)
  static const chooseClassTitle = 'Chọn hạng bằng';
  static const motorbikeGroup = 'Xe máy';
  static const carGroup = 'Ô tô';
  static String className(String c) => 'Hạng $c';
  /// Luật 36/2024/QH15, Điều 57 khoản 1 điểm a, b, d — verbatim, without "cấp cho người lái".
  static const classVehicles = {
    'A1': 'Xe mô tô hai bánh có dung tích xi-lanh đến 125 cm³ hoặc có công suất động cơ điện đến 11 kW',
    'A': 'Xe mô tô hai bánh có dung tích xi-lanh trên 125 cm³ hoặc có công suất động cơ điện trên 11 kW '
        'và các loại xe quy định cho giấy phép lái xe hạng A1',
    'B': 'Xe ô tô chở người đến 08 chỗ (không kể chỗ của người lái xe); xe ô tô tải và ô tô chuyên dùng '
        'có khối lượng toàn bộ theo thiết kế đến 3.500 kg; các loại xe ô tô quy định cho giấy phép lái xe '
        'hạng B kéo rơ moóc có khối lượng toàn bộ theo thiết kế đến 750 kg',
  };
  static String classFacts(int questions, int minutes, int pass) =>
      '$questions câu · $minutes phút · đạt từ $pass câu đúng';

  // Home (ST-04)
  static const changeClass = 'Đổi hạng';
  static const about = 'Giới thiệu';
  static const homeError = 'Không đọc được tiến độ học trên máy. Hãy thử mở lại ứng dụng.';
  static const studyProgress = 'Tiến độ ôn tập';
  static String progressCount(int correct, int total) => '$correct / $total câu';
  static const progressHint = 'Tính các câu trả lời đúng ở lần làm gần nhất';
  static const studyByTopic = 'Học theo chủ đề';
  static const practiceExam = 'Thi thử';
  static const reviewWrong = 'Ôn câu sai';
  static const criticalQuestions = 'Câu điểm liệt';
  static const trafficSigns = 'Biển báo';
  static String questionCount(int n) => '$n câu';
  static const resumeExam = 'Tiếp tục bài thi';
  static const examTimeUp = 'Đã hết giờ — mở để xem kết quả';
  static String timeLeft(Duration d) =>
      'Còn ${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  static const comingSoon = 'Chức năng đang được làm.';

  // Change class with an unfinished test (ST-04 AC2, UC-02 2b)
  static const abandonExamTitle = 'Bỏ bài thi đang làm?';
  static String abandonExamBody(String oldClass) =>
      'Bạn đang làm dở một bài thi hạng $oldClass. Đổi hạng sẽ bỏ bài thi này và không tính kết quả.';
  static const abandonExam = 'Bỏ bài thi';
  static const cancel = 'Hủy';

  // Question view (ST-05)
  static String questionNumber(int position) => 'Câu $position';
  static String officialNumber(int number) => 'Số gốc $number';
  static const criticalBadge = 'Điểm liệt';
  static const notAnswered = 'Chưa trả lời';
  static String answerLabel(int number) => 'Đáp án $number';
  static const answerChosen = 'Đang chọn';
  static const answerCorrect = 'Đáp án đúng';
  static const answerWrong = 'Bạn chọn sai';
  static const zoomImage = 'Hình minh họa. Chạm để phóng to';
  static const questionImage = 'Hình minh họa câu hỏi';
  static const close = 'Đóng';

  // Study by topic (ST-06)
  static const topicAll = 'Tất cả câu hỏi';
  static const topicCritical = 'Câu điểm liệt';
  static String chapterTitle(int chapter, String name) => 'Chương ${_roman(chapter)}. $name';
  static String wrongOfTopic(String title) => 'Câu sai — $title';
  static String topicStats(int correct, int wrong, int notDone) =>
      'Đúng $correct · Sai $wrong · Chưa làm $notDone';
  static String questionOfTotal(int position, int total) => 'Câu $position / $total';
  static const previousQuestion = 'Câu trước';
  static const nextQuestion = 'Câu sau';
  static const chooseQuestion = 'Chọn câu';
  static const restartTopic = 'Làm lại';
  static const restartTopicHint = 'Xóa đáp án đang hiện trong chủ đề này để làm lại từ đầu. Tiến độ và danh sách câu sai vẫn giữ.';
  static const topicFinished = 'Hoàn thành chủ đề';
  static String roundResult(int correct, int wrong, int total) => 'Đúng $correct · Sai $wrong / $total câu';
  static const reviewTopicWrong = 'Ôn câu sai của chủ đề';
  static const goBack = 'Quay lại';
  static const reviewRemainingWrong = 'Ôn tiếp câu còn sai';
  static const noWrongYet = 'Bạn chưa có câu sai';
  static const noWrongYetHint = 'Làm bài thi thử để biết câu nào mình còn chưa chắc.';
  static const noWrongInTopic = 'Không còn câu sai nào trong chủ đề này.';
  static const emptyTopic = 'Chủ đề này chưa có câu hỏi.';
  static const topicNotFound = 'Không tìm thấy chủ đề.';
  static const saveAnswerFailed = 'Không lưu được câu trả lời. Hãy thử lại.';
  static const studyError = 'Không đọc được dữ liệu học trên máy. Hãy thử mở lại ứng dụng.';

  static String _roman(int n) => const ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'][n - 1];
}
