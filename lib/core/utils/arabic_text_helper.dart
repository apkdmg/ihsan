import 'arabic_reshaper/arabic_reshaper.dart';
import 'arabic_reshaper/src/reshaper_config.dart';

class ArabicTextHelper {
  static final _reshaper = ArabicReshaper(
    configuration: ArabicReshaperConfig(
      deleteHarakat: false,
      deleteTatweel: false,
      supportLigatures: true,
    ),
  );

  /// Reshapes Arabic text so that ligatures like Lam-Alif are correctly
  /// formed at the Dart string level before hitting Flutter's rendering engine.
  static String reshape(String text) {
    if (text.isEmpty) return text;
    // Fast path: if no arabic characters, return as is
    if (!text.contains(
      RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
      ),
    )) {
      return text;
    }
    return _reshaper.reshape(text);
  }
}
