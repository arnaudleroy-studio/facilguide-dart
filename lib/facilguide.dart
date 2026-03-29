/// FacilGuide - Multilingual content utilities for tech guides.
///
/// Locale detection, string translation, reading time estimation,
/// and accessibility helpers for building guides in English, Spanish,
/// French, Portuguese, and Italian.
///
/// See https://facil.guide for the full platform.
library facilguide;

/// Current library version.
const String version = '0.1.1';

/// Base URL for the Facil.guide platform.
const String baseUrl = 'https://facil.guide';

// ---------------------------------------------------------------------------
// Supported languages
// ---------------------------------------------------------------------------

/// A supported language on the Facil.guide platform.
class Language {
  /// ISO 639-1 code (en, es, fr, pt, it).
  final String code;

  /// Native-language display name.
  final String nativeName;

  /// English display name.
  final String englishName;

  /// Text direction (always ltr for these languages).
  final String direction;

  const Language({
    required this.code,
    required this.nativeName,
    required this.englishName,
    this.direction = 'ltr',
  });

  @override
  String toString() => 'Language($code, $englishName)';
}

/// All languages supported by Facil.guide.
const List<Language> supportedLanguages = [
  Language(code: 'en', nativeName: 'English', englishName: 'English'),
  Language(code: 'es', nativeName: 'Espanol', englishName: 'Spanish'),
  Language(code: 'fr', nativeName: 'Francais', englishName: 'French'),
  Language(code: 'pt', nativeName: 'Portugues', englishName: 'Portuguese'),
  Language(code: 'it', nativeName: 'Italiano', englishName: 'Italian'),
];

/// Set of valid language codes for quick validation.
const Set<String> validCodes = {'en', 'es', 'fr', 'pt', 'it'};

/// Returns `true` if [code] is a supported language code.
bool isSupportedLanguage(String code) => validCodes.contains(code);

/// Looks up a [Language] by its ISO code, or returns `null`.
Language? findLanguage(String code) =>
    supportedLanguages.where((l) => l.code == code).firstOrNull;

// ---------------------------------------------------------------------------
// Translation
// ---------------------------------------------------------------------------

/// A lightweight translation store.
///
/// Load translation maps per language, then retrieve strings by key.
/// Missing keys fall back to the [defaultLanguage].
class Translator {
  /// Language code used when a key is not found in the requested locale.
  final String defaultLanguage;

  final Map<String, Map<String, String>> _translations = {};

  /// Creates a [Translator] with the given [defaultLanguage] (defaults to `en`).
  Translator({this.defaultLanguage = 'en'});

  /// Registers a [map] of key-value translations for a [languageCode].
  void addTranslations(String languageCode, Map<String, String> map) {
    _translations[languageCode] = {...?_translations[languageCode], ...map};
  }

  /// Returns the translated string for [key] in [languageCode].
  ///
  /// Falls back to [defaultLanguage] if the key is missing, and returns
  /// the raw key if no translation exists at all.
  String translate(String key, {required String languageCode}) {
    return _translations[languageCode]?[key] ??
        _translations[defaultLanguage]?[key] ??
        key;
  }

  /// Shorthand for [translate]. Allows calling the translator like a function.
  String call(String key, {required String languageCode}) =>
      translate(key, languageCode: languageCode);

  /// Returns the number of registered languages.
  int get languageCount => _translations.length;

  /// Returns all language codes that have at least one translation.
  Set<String> get loadedLanguages => _translations.keys.toSet();
}

// ---------------------------------------------------------------------------
// URL routing
// ---------------------------------------------------------------------------

/// Extracts the language prefix from a URL [path].
///
/// Returns the two-letter code if the path starts with a supported
/// language prefix (e.g., `/es/guia/...` returns `es`), or [fallback]
/// if no prefix is found.
String detectLanguageFromPath(String path, {String fallback = 'en'}) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isNotEmpty && isSupportedLanguage(segments.first)) {
    return segments.first;
  }
  return fallback;
}

/// Builds a localized URL path by prepending the language [code].
///
/// English paths omit the prefix (e.g., `/guides/setup`) while other
/// languages include it (e.g., `/es/guides/setup`).
String localizedPath(String path, {required String code}) {
  final clean = path.startsWith('/') ? path : '/$path';
  if (code == 'en') return clean;
  return '/$code$clean';
}

/// Generates hreflang alternate URLs for a given [path].
///
/// Returns a map from language code to full URL, suitable for
/// producing `<link rel="alternate" hreflang="...">` tags.
Map<String, String> hreflangUrls(String path) {
  final urls = <String, String>{};
  for (final lang in supportedLanguages) {
    urls[lang.code] = '$baseUrl${localizedPath(path, code: lang.code)}';
  }
  return urls;
}

// ---------------------------------------------------------------------------
// Reading time & accessibility
// ---------------------------------------------------------------------------

/// Average words per minute by language.
///
/// Seniors typically read at a slower pace; these values are calibrated
/// for a 55+ audience rather than the general-population averages.
const Map<String, int> _readingSpeed = {
  'en': 180,
  'es': 170,
  'fr': 170,
  'pt': 165,
  'it': 165,
};

/// Estimates reading time in minutes for [text] in the given [languageCode].
///
/// Uses language-specific reading speeds calibrated for a senior audience.
int readingTimeMinutes(String text, {String languageCode = 'en'}) {
  if (text.trim().isEmpty) return 0;
  final wordCount = text.trim().split(RegExp(r'\s+')).length;
  final wpm = _readingSpeed[languageCode] ?? 180;
  return (wordCount / wpm).ceil();
}

/// Returns a recommended minimum font size in pixels for the given
/// content [type].
///
/// Accessibility guidelines for senior-focused content suggest larger
/// base sizes than standard web defaults.
int recommendedFontSize({String type = 'body'}) {
  switch (type) {
    case 'heading':
      return 28;
    case 'subheading':
      return 22;
    case 'body':
      return 18;
    case 'caption':
      return 16;
    default:
      return 18;
  }
}

/// Returns a recommended line height multiplier for the given content [type].
double recommendedLineHeight({String type = 'body'}) {
  switch (type) {
    case 'heading':
      return 1.3;
    case 'body':
      return 1.8;
    default:
      return 1.6;
  }
}
