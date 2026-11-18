import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/assistant_message.dart';
import 'assistant_response_renderer.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    required this.message,
    required this.isLatestQuestion,
    required this.isLatestAnswer,
    required this.onCopy,
    required this.onShare,
    required this.onEdit,
    required this.onRegenerate,
    required this.onFeedback,
    required this.onSave,
    super.key,
  });

  final AssistantMessage message;
  final bool isLatestQuestion;
  final bool isLatestAnswer;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onRegenerate;
  final ValueChanged<AssistantMessageFeedback?> onFeedback;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == AssistantMessageSender.user;
    final scheme = Theme.of(context).colorScheme;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = isUser
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        child: Card(
          color: background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'Vous' : 'Naru AI · démonstration',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                if (isUser)
                  SelectableText(message.content)
                else
                  AssistantResponseRenderer(content: message.content),
                const SizedBox(height: AppSpacing.small),
                Text(
                  TimeOfDay.fromDateTime(message.createdAt).format(context),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (isUser && isLatestQuestion)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Modifier'),
                    ),
                  ),
                if (!isUser) ...[
                  const Divider(height: AppSpacing.large),
                  Wrap(
                    spacing: AppSpacing.verySmall,
                    runSpacing: AppSpacing.verySmall,
                    children: [
                      IconButton(
                        tooltip: 'Copier la réponse',
                        onPressed: onCopy,
                        icon: const Icon(Icons.copy_rounded),
                      ),
                      IconButton(
                        tooltip: 'Copier pour partager',
                        onPressed: onShare,
                        icon: const Icon(Icons.ios_share_rounded),
                      ),
                      if (isLatestAnswer)
                        IconButton(
                          tooltip: 'Régénérer la réponse de démonstration',
                          onPressed: onRegenerate,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                        IconButton(
                          tooltip: 'Ajouter aux favoris',
                          onPressed: onSave,
                          icon: const Icon(Icons.bookmark_border_rounded),
                        ),
                      IconButton(
                        tooltip: 'Réponse utile',
                        onPressed: () => onFeedback(
                          message.feedback == AssistantMessageFeedback.helpful
                              ? null
                              : AssistantMessageFeedback.helpful,
                        ),
                        color:
                            message.feedback == AssistantMessageFeedback.helpful
                            ? scheme.primary
                            : null,
                        icon: const Icon(Icons.thumb_up_outlined),
                      ),
                      IconButton(
                        tooltip: 'Réponse à améliorer',
                        onPressed: () => onFeedback(
                          message.feedback ==
                                  AssistantMessageFeedback.notHelpful
                              ? null
                              : AssistantMessageFeedback.notHelpful,
                        ),
                        color:
                            message.feedback ==
                                AssistantMessageFeedback.notHelpful
                            ? scheme.primary
                            : null,
                        icon: const Icon(Icons.thumb_down_outlined),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
