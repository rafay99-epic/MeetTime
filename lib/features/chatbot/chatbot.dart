import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meettime/core/provider/chat_bot_provider.dart';
import 'package:meettime/features/chatbot/widgets/bubble_message.dart';
import 'package:meettime/features/chatbot/widgets/input_area.dart';
import 'package:meettime/features/chatbot/widgets/typing/indicator/type_indicator.dart';
import 'package:meettime/widgets/appbar.dart';
import 'package:provider/provider.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatbotProvider = Provider.of<ChatbotProvider>(context);
    final TextEditingController messageController = TextEditingController();
    final FocusNode messageFocusNode = FocusNode();

    void sendMessage() {
      final userMessage = messageController.text.trim();
      if (userMessage.isNotEmpty) {
        chatbotProvider.sendMessage(userMessage);
        messageController.clear();
        messageFocusNode.requestFocus();
      }
    }

    void copyToClipboard(String message) {
      Clipboard.setData(ClipboardData(text: message));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message copied to clipboard'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Scaffold(
      appBar: const MeetTimeAppBar(
        title: 'Chatbot',
        showBack: false,
        showSettings: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: chatbotProvider.messages.length +
                  (chatbotProvider.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (chatbotProvider.isTyping && index == 0) {
                  return const TypingIndicator();
                }

                final message = chatbotProvider.messages.reversed
                    .toList()[index - (chatbotProvider.isTyping ? 1 : 0)];
                final isUserMessage = message["role"] == "user";
                return buildMessageBubble(
                  message["content"]!,
                  isUserMessage,
                  context,
                  copyToClipboard,
                );
              },
            ),
          ),
          buildInputArea(
            messageController,
            messageFocusNode,
            sendMessage,
            context,
          ),
        ],
      ),
    );
  }
}
