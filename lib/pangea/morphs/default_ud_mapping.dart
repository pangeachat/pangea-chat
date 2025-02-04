import 'package:fluffychat/pangea/morphs/morph_models.dart';

final MorphFeaturesAndTags defaultUDMapping = MorphFeaturesAndTags.fromJson({
  "language_code": "default",
  "features": [
    {
      "feature": "pos",
      "tag": [
        "ADJ",
        "ADP",
        "ADV",
        "AFFIX",
        "AUX",
        "CCONJ",
        "DET",
        "INTJ",
        "NOUN",
        "NUM",
        "PART",
        "PRON",
        "PROPN",
        "PUNCT",
        "SCONJ",
        "SPACE",
        "SYM",
        "VERB",
        "X",
      ],
    },
    {
      "feature": "advtype",
      "tag": ["Adverbial", "Tim"],
    },
    {
      "feature": "aspect",
      "tag": ["Imp", "Perf", "Prog", "Hab"],
    },
    {
      "feature": "case",
      "tag": [
        "Nom",
        "Acc",
        "Dat",
        "Gen",
        "Voc",
        "Abl",
        "Loc",
        "All",
        "Ins",
        "Ess",
        "Tra",
        "Com",
        "Par",
        "Adv",
        "Ref",
        "Rel",
        "Equ",
        "Dis",
        "Abs",
        "Erg",
        "Cau",
        "Ben",
        "Sub",
        "Sup",
        "Tem",
        "Obl",
        "Acc,Dat",
        "Acc,Nom",
        "Pre",
      ],
    },
    {
      "feature": "conjtype",
      "tag": ["Coord", "Sub", "Cmp"],
    },
    {
      "feature": "definite",
      "tag": ["Def", "Ind", "Cons"],
    },
    {
      "feature": "degree",
      "tag": ["Pos", "Cmp", "Sup", "Abs"],
    },
    {
      "feature": "evident",
      "tag": ["Fh", "Nfh"],
    },
    {
      "feature": "foreign",
      "tag": ["Yes"],
    },
    {
      "feature": "gender",
      "tag": ["Masc", "Fem", "Neut", "Com"],
    },
    {
      "feature": "mood",
      "tag": [
        "Ind",
        "Imp",
        "Sub",
        "Cnd",
        "Opt",
        "Jus",
        "Adm",
        "Des",
        "Nec",
        "Pot",
        "Prp",
        "Qot",
        "Int",
      ],
    },
    {
      "feature": "nountype",
      "tag": ["Prop", "Comm", "Not_proper"],
    },
    {
      "feature": "numform",
      "tag": ["Digit", "Word", "Roman", "Letter"],
    },
    {
      "feature": "numtype",
      "tag": ["Card", "Ord", "Mult", "Frac", "Sets", "Range", "Dist"],
    },
    {
      "feature": "number",
      "tag": ["Sing", "Plur", "Dual", "Tri", "Pauc", "Grpa", "Grpl", "Inv"],
    },
    {
      "feature": "number[psor]",
      "tag": ["Sing", "Plur", "Dual"],
    },
    {
      "feature": "person",
      "tag": ["0", "1", "2", "3", "4"],
    },
    {
      "feature": "polarity",
      "tag": ["Pos", "Neg"],
    },
    {
      "feature": "polite",
      "tag": ["Infm", "Form", "Elev", "Humb"],
    },
    {
      "feature": "poss",
      "tag": ["Yes"],
    },
    {
      "feature": "prepcase",
      "tag": ["Npr"],
    },
    {
      "feature": "prontype",
      "tag": [
        "Prs",
        "Int",
        "Rel",
        "Dem",
        "Tot",
        "Neg",
        "Art",
        "Emp",
        "Exc",
        "Ind",
        "Rcp",
        "Int,Rel",
      ],
    },
    {
      "feature": "punctside",
      "tag": ["Ini", "Fin"],
    },
    {
      "feature": "puncttype",
      "tag": [
        "Brck",
        "Dash",
        "Excl",
        "Peri",
        "Qest",
        "Quot",
        "Semi",
        "Colo",
        "Comm",
      ],
    },
    {
      "feature": "reflex",
      "tag": ["Yes"],
    },
    {
      "feature": "tense",
      "tag": ["Pres", "Past", "Fut", "Imp", "Pqp", "Aor", "Eps", "Prosp"],
    },
    {
      "feature": "verbform",
      "tag": [
        "Fin",
        "Inf",
        "Sup",
        "Part",
        "Conv",
        "Vnoun",
        "Ger",
        "Adn",
        "Lng",
      ],
    },
    {
      "feature": "verbtype",
      "tag": ["Mod", "Caus"],
    },
    {
      "feature": "voice",
      "tag": [
        "Act",
        "Mid",
        "Pass",
        "Antip",
        "Cau",
        "Dir",
        "Inv",
        "Rcp",
        "Caus",
      ],
    },
    {
      "feature": "x",
      "tag": ["X"],
    }
  ],
});
