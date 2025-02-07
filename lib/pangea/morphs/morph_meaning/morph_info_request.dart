class MorphInfoRequest {
  final String morphTag;
  final String morphFeature;
  final String lemmaLang;
  final String userL1;

  MorphInfoRequest({
    required String morphFeature,
    required String lemmaLang,
    required this.userL1,
    required this.morphTag,
  })  : morphFeature = morphFeature.toLowerCase(),
        lemmaLang = lemmaLang.toLowerCase();

  Map<String, dynamic> toJson() {
    return {
      'morph_tag': morphTag,
      'morph_feature': morphFeature,
      'lemma_lang': lemmaLang,
      'user_l1': userL1,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphInfoRequest &&
          runtimeType == other.runtimeType &&
          morphTag == other.morphTag &&
          morphFeature == other.morphFeature;

  @override
  int get hashCode => morphTag.hashCode ^ morphFeature.hashCode;

  String get storageKey {
    return 'l:$morphTag,p:$morphFeature,lang:$lemmaLang,l1:$userL1';
  }
}
