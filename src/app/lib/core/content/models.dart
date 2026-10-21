// Read-only content models (ADR-003). Pure Dart: no Flutter import, so domain code and tests stay platform-free.

class Question {
  const Question({
    required this.id,
    required this.number,
    required this.chapter,
    required this.content,
    required this.images,
    required this.options,
    required this.correctIndex,
    required this.criticalFor,
    required this.licenseClasses,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
    id: j['id'] as String,
    number: j['number'] as int,
    chapter: j['chapter'] as int,
    content: j['content'] as String,
    images: List<String>.from(j['images'] as List<dynamic>),
    options: List<String>.from(j['options'] as List<dynamic>),
    correctIndex: j['correctIndex'] as int,
    criticalFor: List<String>.from(j['criticalFor'] as List<dynamic>),
    licenseClasses: List<String>.from(j['licenseClasses'] as List<dynamic>),
  );

  final String id;
  final int number;
  final int chapter;
  final String content;
  final List<String> images;
  final List<String> options;
  final int correctIndex;
  final List<String> criticalFor;
  final List<String> licenseClasses;

  bool isCriticalFor(String licenseClass) => criticalFor.contains(licenseClass);
  bool inPool(String licenseClass) => licenseClasses.contains(licenseClass);
}

/// One group of a test blueprint: either the critical question or N questions from some chapters.
class DistributionGroup {
  const DistributionGroup({
    required this.critical,
    required this.chapters,
    required this.count,
  });

  factory DistributionGroup.fromJson(Map<String, dynamic> j) =>
      DistributionGroup(
        critical: j['group'] == 'critical',
        chapters: j['chapters'] == null
            ? const []
            : List<int>.from(j['chapters'] as List<dynamic>),
        count: j['count'] as int,
      );

  final bool critical;
  final List<int> chapters;
  final int count;
}

class ExamStructure {
  const ExamStructure({
    required this.id,
    required this.licenseClass,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.questionCount,
    required this.durationMinutes,
    required this.passScore,
    required this.pool,
    required this.distribution,
    required this.complete,
  });

  factory ExamStructure.fromJson(Map<String, dynamic> j) => ExamStructure(
    id: j['id'] as String,
    licenseClass: j['licenseClass'] as String,
    effectiveFrom: DateTime.parse(j['effectiveFrom'] as String),
    effectiveTo: j['effectiveTo'] == null
        ? null
        : DateTime.parse(j['effectiveTo'] as String),
    questionCount: j['questionCount'] as int,
    durationMinutes: j['durationMinutes'] as int,
    passScore: j['passScore'] as int,
    pool: j['pool'] as String?,
    distribution: j['distribution'] == null
        ? const []
        : [
            for (final g in j['distribution'] as List<dynamic>)
              DistributionGroup.fromJson(g as Map<String, dynamic>),
          ],
    complete: j['status'] != 'incomplete',
  );

  final String id;
  final String licenseClass;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final int questionCount;
  final int durationMinutes;
  final int passScore;
  final String? pool;
  final List<DistributionGroup> distribution;

  /// False for structures announced by TT 108/2026 without a question bank yet (BR-08).
  final bool complete;
}

class TrafficSign {
  const TrafficSign({
    required this.code,
    required this.name,
    required this.group,
    required this.groupName,
    required this.summary,
    required this.meaning,
    required this.images,
    this.noImageReason,
  });

  factory TrafficSign.fromJson(Map<String, dynamic> j) => TrafficSign(
    code: j['code'] as String,
    name: j['name'] as String,
    group: j['group'] as String,
    groupName: j['groupName'] as String,
    summary: (j['summary'] as String?) ?? '',
    meaning: j['meaning'] as String,
    images: List<String>.from(j['images'] as List<dynamic>),
    noImageReason: j['noImageReason'] as String?,
  );

  final String code;
  final String name;
  final String group;
  final String groupName;
  final String summary;
  final String meaning;
  final List<String> images;

  /// Why there is no picture (e.g. QCVN has no figure for marking 3.4); null when [images] is not empty.
  final String? noImageReason;
}

/// Everything the app reads from assets, parsed once at start-up.
class ContentBundle {
  const ContentBundle({
    required this.version,
    required this.questions,
    required this.structures,
    required this.signs,
    required this.signGroups,
    this.chapters = const {},
  });

  final String version;
  final List<Question> questions;
  final List<ExamStructure> structures;
  final List<TrafficSign> signs;

  /// group key -> display name, in catalog order.
  final Map<String, String> signGroups;

  /// Chapter number -> official name (CV 2262 §I.1).
  final Map<int, String> chapters;
}

/// Parses the four JSON documents written by tools/sync_assets.py. Throws [FormatException] on bad data.
ContentBundle parseContent(Map<String, dynamic> docs) {
  try {
    final bank = docs['questions'] as Map<String, dynamic>;
    final structures = docs['structures'] as Map<String, dynamic>;
    final signs = docs['signs'] as Map<String, dynamic>;
    final version = docs['version'] as Map<String, dynamic>;
    return ContentBundle(
      version: version['contentVersion'] as String,
      questions: [
        for (final q in bank['questions'] as List<dynamic>)
          Question.fromJson(q as Map<String, dynamic>),
      ],
      structures: [
        for (final s in structures['structures'] as List<dynamic>)
          ExamStructure.fromJson(s as Map<String, dynamic>),
      ],
      signs: [
        for (final s in signs['signs'] as List<dynamic>)
          TrafficSign.fromJson(s as Map<String, dynamic>),
      ],
      signGroups: Map<String, String>.from(
        signs['groups'] as Map<String, dynamic>,
      ),
      chapters: {
        for (final e in (bank['chapters'] as Map<String, dynamic>).entries)
          int.parse(e.key): e.value as String,
      },
    );
  } on TypeError catch (e) {
    throw FormatException('Dữ liệu nội dung không đúng cấu trúc: $e');
  }
}
