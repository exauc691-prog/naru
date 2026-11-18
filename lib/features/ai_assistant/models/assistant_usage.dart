import '../../../shared/models/model_json.dart';

enum AssistantQuotaKind {
  messages,
  documentAnalyses,
  generations,
  voiceMinutes,
}

class AssistantUsage {
  AssistantUsage({
    required this.dateKey,
    Map<AssistantQuotaKind, int> counts = const {},
  }) : counts = Map.unmodifiable(counts);

  final String dateKey;
  final Map<AssistantQuotaKind, int> counts;

  int count(AssistantQuotaKind kind) => counts[kind] ?? 0;

  AssistantUsage increment(AssistantQuotaKind kind) => AssistantUsage(
    dateKey: dateKey,
    counts: {...counts, kind: count(kind) + 1},
  );

  AssistantUsage forDate(DateTime date) {
    final key = _dateKey(date);
    return key == dateKey ? this : AssistantUsage(dateKey: key);
  }

  factory AssistantUsage.today(DateTime date) =>
      AssistantUsage(dateKey: _dateKey(date));

  factory AssistantUsage.fromJson(ModelJsonMap json) {
    final rawCounts = ModelJson.object(json['counts'], 'counts');
    final counts = <AssistantQuotaKind, int>{};
    for (final kind in AssistantQuotaKind.values) {
      final value = rawCounts[kind.name];
      if (value == null) continue;
      if (value is! int || value < 0) {
        throw FormatException('Invalid count for "${kind.name}".');
      }
      counts[kind] = value;
    }
    return AssistantUsage(
      dateKey: ModelJson.requiredString(json, 'dateKey'),
      counts: counts,
    );
  }

  ModelJsonMap toJson() => {
    'dateKey': dateKey,
    'counts': {for (final entry in counts.entries) entry.key.name: entry.value},
  };
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
