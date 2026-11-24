import 'package:injectable/injectable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:saveit/features/chat/data/data_sources/local_responses.dart';

@lazySingleton
class ChatReplySource {
  static const String _apiKey = String.fromEnvironment('SAVEIT_GEMINI_API_KEY');

  Future<String> sendMessage(String text) async {
    final localReply = LocalResponses.getReply(text);

    if (_apiKey.isEmpty) return localReply;

    if (localReply == "مفهمتش قصدك، ممكن تعيد صياغة السؤال؟" ||
        localReply == "ممكن توضح أكتر؟" ||
        localReply == "آسف مش فاهمك، ممكن تكرر اللي قولته؟" ||
        localReply == "ممكن تعيد تاني؟" ||
        localReply == "معلش مش واضح، ممكن تقول بطريقة تانية؟") {
      try {
        final model = GenerativeModel(
          model: "gemini-1.5-flash",
          apiKey: _apiKey,
        );

        final content = [Content.text(text)];
        final response = await model.generateContent(content);

        return response.text ?? localReply;
      } catch (_) {
        return "حصل خطأ أثناء محاولة الفهم";
      }
    } else {
      return localReply;
    }
  }
}
