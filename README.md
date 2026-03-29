# facilguide

[![pub package](https://img.shields.io/pub/v/facilguide.svg)](https://pub.dev/packages/facilguide)

Multilingual content utilities for building accessible tech guides from [Facil.guide](https://facil.guide). Handles locale detection, string translation with fallback, localized URL routing, hreflang generation, reading time estimation for senior audiences, and accessibility recommendations across five languages: English, Spanish, French, Portuguese, and Italian.

## Installation

```yaml
dependencies:
  facilguide: ^0.1.1
```

Or install from the command line:

```bash
dart pub add facilguide
```

## Quick Start

### Language Detection and Routing

```dart
import 'package:facilguide/facilguide.dart';

void main() {
  // Detect language from a URL path
  print(detectLanguageFromPath('/es/guia/wifi'));  // es
  print(detectLanguageFromPath('/guides/setup'));   // en (default)

  // Build localized paths
  print(localizedPath('/guides/wifi', code: 'en')); // /guides/wifi
  print(localizedPath('/guides/wifi', code: 'fr')); // /fr/guides/wifi
  print(localizedPath('/guides/wifi', code: 'pt')); // /pt/guides/wifi

  // Generate hreflang URLs for SEO
  final alternates = hreflangUrls('/guides/wifi');
  alternates.forEach((lang, url) {
    print('$lang -> $url');
  });
  // en -> https://facil.guide/guides/wifi
  // es -> https://facil.guide/es/guides/wifi
  // fr -> https://facil.guide/fr/guides/wifi
  // pt -> https://facil.guide/pt/guides/wifi
  // it -> https://facil.guide/it/guides/wifi
}
```

### Translation System

The Translator class stores key-value pairs per language and falls back gracefully when a translation is missing.

```dart
import 'package:facilguide/facilguide.dart';

void main() {
  final t = Translator(defaultLanguage: 'en')
    ..addTranslations('en', {
      'nav.home': 'Home',
      'nav.guides': 'Guides',
      'nav.about': 'About',
    })
    ..addTranslations('es', {
      'nav.home': 'Inicio',
      'nav.guides': 'Guias',
    });

  print(t.translate('nav.home', languageCode: 'es'));   // Inicio
  print(t.translate('nav.about', languageCode: 'es'));  // About (fallback)
  print(t.languageCount); // 2
}
```

### Reading Time and Accessibility

Estimates are calibrated for a senior audience (55+), using slower reading speeds than general-population averages.

```dart
import 'package:facilguide/facilguide.dart';

void main() {
  final article = List.generate(900, (i) => 'word').join(' ');

  // Reading time varies by language speed
  print(readingTimeMinutes(article, languageCode: 'en')); // 5 min
  print(readingTimeMinutes(article, languageCode: 'pt')); // 6 min

  // Accessibility recommendations for senior-focused content
  print(recommendedFontSize(type: 'body'));      // 18
  print(recommendedFontSize(type: 'heading'));   // 28
  print(recommendedLineHeight(type: 'body'));    // 1.8
}
```

### Working with Languages

```dart
import 'package:facilguide/facilguide.dart';

void main() {
  // Validate language codes
  print(isSupportedLanguage('es')); // true
  print(isSupportedLanguage('de')); // false

  // Look up language metadata
  final lang = findLanguage('it');
  print(lang?.nativeName);  // Italiano
  print(lang?.englishName); // Italian

  // Iterate all supported languages
  for (final lang in supportedLanguages) {
    print('${lang.code}: ${lang.nativeName}');
  }
}
```

## Available Features

This package addresses the specific needs of multilingual, accessibility-first content platforms. The URL router detects language prefixes and generates localized paths following the pattern where English is unprefixed and other languages use a two-letter prefix. The hreflang generator produces alternate URLs for all five supported languages, ready for SEO meta tags. Reading time estimation uses per-language words-per-minute rates tuned for older adults rather than general web averages. Accessibility helpers provide font size and line height recommendations that follow senior-focused usability research.

## Links

- Website: [https://facil.guide](https://facil.guide)
- Repository: [https://github.com/arnaudleroy-studio/facilguide-dart](https://github.com/arnaudleroy-studio/facilguide-dart)

## License

MIT. See [LICENSE](LICENSE) for details.
