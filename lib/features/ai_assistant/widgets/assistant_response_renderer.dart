import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AssistantResponseRenderer extends StatelessWidget {
  const AssistantResponseRenderer({required this.content, super.key});

  final String content;

  static final _codeBlock = RegExp(r'```([a-zA-Z0-9_-]*)\s*\n([\s\S]*?)```');
  static final _inlineFormatting = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`)');

  @override
  Widget build(BuildContext context) {
    final segments = <Widget>[];
    var cursor = 0;
    for (final match in _codeBlock.allMatches(content)) {
      if (match.start > cursor) {
        segments.addAll(
          _paragraphWidgets(content.substring(cursor, match.start)),
        );
      }
      segments.add(
        _codeCard(context, match.group(1) ?? '', match.group(2) ?? ''),
      );
      cursor = match.end;
    }
    if (cursor < content.length) {
      segments.addAll(_paragraphWidgets(content.substring(cursor)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < segments.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.small),
          segments[index],
        ],
      ],
    );
  }

  List<Widget> _paragraphWidgets(String text) {
    final lines = text.trim().split('\n');
    final widgets = <Widget>[];
    for (var index = 0; index < lines.length;) {
      final line = lines[index].trimRight();
      if (line.trim().isEmpty) {
        index++;
        continue;
      }
      if (line.startsWith('|')) {
        final tableLines = <String>[];
        while (index < lines.length && lines[index].startsWith('|')) {
          tableLines.add(lines[index++]);
        }
        widgets.add(_table(tableLines));
        continue;
      }
      if (line.startsWith('- ')) {
        final bullets = <String>[];
        while (index < lines.length && lines[index].startsWith('- ')) {
          bullets.add(lines[index++].substring(2));
        }
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text.rich(_spans(item))),
                    ],
                  ),
                ),
            ],
          ),
        );
        continue;
      }
      final numbered = RegExp(r'^\d+\.\s+(.*)$').firstMatch(line);
      if (numbered != null) {
        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${RegExp(r'^\d+').firstMatch(line)!.group(0)}.  '),
              Expanded(child: Text.rich(_spans(numbered.group(1)!))),
            ],
          ),
        );
        index++;
        continue;
      }
      if (line.startsWith('> ')) {
        widgets.add(
          Builder(
            builder: (context) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text.rich(_spans(line.substring(2))),
            ),
          ),
        );
        index++;
        continue;
      }
      final heading = RegExp(r'^#{1,3}\s+(.+)$').firstMatch(line);
      if (heading != null) {
        widgets.add(
          Text(
            heading.group(1)!,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
        index++;
        continue;
      }
      if (_isFormula(line)) {
        widgets.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.small),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formulaText(line),
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        );
        index++;
        continue;
      }
      if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(
          Text(
            line.substring(2, line.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
        index++;
        continue;
      }
      widgets.add(Text.rich(_spans(line)));
      index++;
    }
    return widgets;
  }

  TextSpan _spans(String text) {
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _inlineFormatting.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final value = match.group(0)!;
      final isBold = value.startsWith('**');
      spans.add(
        TextSpan(
          text: value.substring(
            isBold ? 2 : 1,
            value.length - (isBold ? 2 : 1),
          ),
          style: isBold
              ? const TextStyle(fontWeight: FontWeight.w700)
              : const TextStyle(fontFamily: 'monospace'),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return TextSpan(children: spans);
  }

  Widget _codeCard(BuildContext context, String language, String code) {
    final palette = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty) ...[
            Text(
              language.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.small),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              code.trim(),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontFamily: 'monospace', height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table(List<String> rows) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows.where(
          (line) => !RegExp(r'^\|[\s:|-]+\|$').hasMatch(line),
        ))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(row, style: const TextStyle(fontFamily: 'monospace')),
          ),
      ],
    ),
  );

  bool _isFormula(String line) =>
      (line.startsWith(r'\(') && line.endsWith(r'\)')) ||
      (line.startsWith(r'\[') && line.endsWith(r'\]')) ||
      (line.startsWith(r'$$') && line.endsWith(r'$$'));

  String _formulaText(String line) => line.substring(2, line.length - 2);
}
