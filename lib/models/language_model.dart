class LanguageModel {
  String pngAsset;
  final String title;
  final String languageCode;
  final String? nativeName;

  LanguageModel({
    required this.pngAsset,
    required this.title,
    required this.languageCode,
    this.nativeName,
  });
}

class LanguageVariantModel {
  final String variantId;
  final String title;
  final String nativeName;
  final String languageCode;
  final String countryCode;
  final String? pngAsset;

  const LanguageVariantModel({
    required this.variantId,
    required this.title,
    required this.nativeName,
    required this.languageCode,
    required this.countryCode,
    this.pngAsset,
  });
}

class LanguageGroupModel {
  final String groupId;
  final String title;
  final String nativeName;
  final String languageCode;
  final String? singleCountryCode;
  final String? pngAsset;
  final List<LanguageVariantModel> variants;

  const LanguageGroupModel({
    required this.groupId,
    required this.title,
    required this.nativeName,
    required this.languageCode,
    this.singleCountryCode,
    this.pngAsset,
    this.variants = const [],
  });

  bool get isDropdown => variants.isNotEmpty;
}
