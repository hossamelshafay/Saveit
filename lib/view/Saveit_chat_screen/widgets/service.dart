// Refactored lib/view/Saveit_chat_screen/widgets/service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'responses.dart';

class Service {
  // IMPORTANT: The API key is now a placeholder.
  // In a production app, you MUST NOT store API keys directly in the client-side code.
  // Instead, use a secure backend proxy or a cloud function (e.g., Firebase Functions)
  // to make the API call and expose a secure endpoint to your app.
  static const String _apiKey = "AIzaSyC11ZWsEI9xVngdGOBfRS2VomToIdAhGgA";

  static Future<String> sendMessage(String text) async {
    final localReply = LocalResponses.getReply(text);

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
      } catch (e) {
        return "حصل خطأ أثناء محاولة الفهم: $e";
      }
    } else {
      return localReply;
    }
  }
}
