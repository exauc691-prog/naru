import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AssistantComposer extends StatefulWidget {
  const AssistantComposer({
    required this.onSend,
    required this.onAttachment,
    required this.onVoice,
    this.initialText = '',
    this.hintText = 'Posez votre question à Naru…',
    this.isEnabled = true,
    super.key,
  });

  final Future<bool> Function(String) onSend;
  final VoidCallback onAttachment;
  final VoidCallback onVoice;
  final String initialText;
  final String hintText;
  final bool isEnabled;

  @override
  State<AssistantComposer> createState() => AssistantComposerState();
}

class AssistantComposerState extends State<AssistantComposer> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant AssistantComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText) {
      _controller.value = TextEditingValue(
        text: widget.initialText,
        selection: TextSelection.collapsed(offset: widget.initialText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void setDraft(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    FocusScope.of(context).requestFocus(_focusNode);
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending || !widget.isEnabled) return;
    setState(() => _sending = true);
    try {
      final sent = await widget.onSend(text);
      if (mounted && sent) _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(context);
    final enabled = widget.isEnabled && !_sending;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.border)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.small,
          AppSpacing.medium,
          AppSpacing.small,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: enabled,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.small),
            Row(
              children: [
                IconButton(
                  tooltip: 'Préparer un document',
                  onPressed: enabled ? widget.onAttachment : null,
                  icon: const Icon(Icons.attach_file_rounded),
                ),
                IconButton(
                  tooltip: 'Aperçu vocal',
                  onPressed: enabled ? widget.onVoice : null,
                  icon: const Icon(Icons.mic_none_rounded),
                ),
                const Spacer(),
                if (_sending)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.small),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton.filled(
                    tooltip: 'Envoyer',
                    onPressed: enabled ? _submit : null,
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
