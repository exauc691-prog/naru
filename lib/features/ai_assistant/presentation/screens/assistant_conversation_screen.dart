import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/assistant_quota_config.dart';
import '../../models/assistant_conversation.dart';
import '../../models/assistant_message.dart';
import '../../models/assistant_mode.dart';
import '../../providers/assistant_providers.dart';
import '../../widgets/assistant_composer.dart';
import '../../widgets/assistant_demo_banner.dart';
import '../../widgets/assistant_feedback.dart';
import '../../widgets/assistant_message_bubble.dart';

class AssistantConversationScreen extends ConsumerStatefulWidget {
  const AssistantConversationScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  ConsumerState<AssistantConversationScreen> createState() =>
      _AssistantConversationScreenState();
}

class _AssistantConversationScreenState
    extends ConsumerState<AssistantConversationScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _send(String text) async {
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .sendMessage(widget.conversationId, text);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        });
      }
      return true;
    } on AssistantQuotaExceeded catch (error) {
      if (mounted) await showAssistantQuotaDialog(context, ref, error);
      return false;
    } catch (error) {
      if (mounted) showAssistantError(context, error);
      return false;
    }
  }

  Future<void> _copy(String text, {bool share = false}) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              share ? 'Réponse copiée pour être partagée.' : 'Réponse copiée.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  Future<void> _editQuestion(AssistantMessage message) async {
    final revised = await showDialog<String>(
      context: context,
      builder: (context) => _EditQuestionDialog(initialText: message.content),
    );
    if (revised == null || !mounted) return;
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .editLastQuestion(widget.conversationId, message.id, revised);
    } on AssistantQuotaExceeded catch (error) {
      if (mounted) await showAssistantQuotaDialog(context, ref, error);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  Future<void> _regenerate() async {
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .regenerateResponse(widget.conversationId);
    } on AssistantQuotaExceeded catch (error) {
      if (mounted) await showAssistantQuotaDialog(context, ref, error);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  Future<void> _setFeedback(
    String messageId,
    AssistantMessageFeedback? feedback,
  ) async {
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .setFeedback(widget.conversationId, messageId, feedback);
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  Future<void> _saveResponse(String messageId) async {
    try {
      await ref
          .read(assistantControllerProvider.notifier)
          .saveResponse(
            conversationId: widget.conversationId,
            messageId: messageId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réponse ajoutée aux favoris.')),
        );
      }
    } catch (error) {
      if (mounted) showAssistantError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assistant = ref.watch(assistantControllerProvider);
    return assistant.when(
      data: (state) {
        AssistantConversation? conversation;
        for (final item in state.conversations) {
          if (item.id == widget.conversationId) {
            conversation = item;
            break;
          }
        }
        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Conversation')),
            body: const Center(
              child: Text('Cette conversation est introuvable.'),
            ),
          );
        }
        final lastQuestionId = _lastMessageFrom(
          conversation.messages,
          AssistantMessageSender.user,
        )?.id;
        final lastAnswerId = _lastMessageFrom(
          conversation.messages,
          AssistantMessageSender.assistant,
        )?.id;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${conversation.mode.label} · mode démonstration',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Nouvelle conversation',
                onPressed: () => context.push(AppRoutes.assistant),
                icon: const Icon(Icons.add_comment_outlined),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'history') {
                    context.push(AppRoutes.assistantHistory);
                  } else {
                    context.push(AppRoutes.assistantSettings);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'history', child: Text('Historique')),
                  PopupMenuItem(
                    value: 'settings',
                    child: Text('Confidentialité et données'),
                  ),
                ],
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.medium,
                        AppSpacing.small,
                        AppSpacing.medium,
                        AppSpacing.medium,
                      ),
                      children: [
                        const AssistantDemoBanner(),
                        const SizedBox(height: AppSpacing.medium),
                        for (final message in conversation.messages)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.medium,
                            ),
                            child: AssistantMessageBubble(
                              message: message,
                              isLatestQuestion: message.id == lastQuestionId,
                              isLatestAnswer: message.id == lastAnswerId,
                              onCopy: () => _copy(message.content),
                              onShare: () =>
                                  _copy(message.content, share: true),
                              onEdit: () => _editQuestion(message),
                              onRegenerate: _regenerate,
                              onFeedback: (feedback) =>
                                  _setFeedback(message.id, feedback),
                              onSave: () => _saveResponse(message.id),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AssistantComposer(
                    onSend: _send,
                    onAttachment: () =>
                        context.push(AppRoutes.assistantDocuments),
                    onVoice: () => context.push(AppRoutes.assistantVoice),
                    isEnabled: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Conversation')),
        body: const Center(
          child: Text('Impossible de charger cette conversation locale.'),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Conversation')),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EditQuestionDialog extends StatefulWidget {
  const _EditQuestionDialog({required this.initialText});

  final String initialText;

  @override
  State<_EditQuestionDialog> createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<_EditQuestionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Modifier votre question'),
    content: TextField(
      controller: _controller,
      minLines: 2,
      maxLines: 5,
      autofocus: true,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Mettre à jour'),
      ),
    ],
  );
}

AssistantMessage? _lastMessageFrom(
  List<AssistantMessage> messages,
  AssistantMessageSender sender,
) {
  for (final message in messages.reversed) {
    if (message.sender == sender) return message;
  }
  return null;
}
